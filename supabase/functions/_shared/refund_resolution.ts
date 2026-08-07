export type RefundDecision = "approved" | "denied";

export interface RefundResolution {
  success: boolean;
  alreadyResolved: boolean;
  refundId: number;
  transactionId: number;
  customerId: string;
  amount: number;
  status: RefundDecision;
  notificationSent: boolean;
}

export interface RefundResolutionDependencies {
  authenticate(req: Request): Promise<string>;
  resolve(input: {
    refundId: number;
    decision: RefundDecision;
    note: string;
    actorUserId: string;
  }): Promise<RefundResolution>;
  notify(resolution: RefundResolution, note: string): Promise<void>;
  markNotificationSent(refundId: number): Promise<void>;
}

export class RefundHttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("CLEAN_STREAM_WEB_ORIGIN") ??
    "https://cleanstreamlaundry.com",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Vary": "Origin",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function requestBody(req: Request): Promise<Record<string, unknown>> {
  try {
    const body = await req.json();
    if (!body || typeof body !== "object" || Array.isArray(body)) {
      throw new Error("Invalid body");
    }
    return body as Record<string, unknown>;
  } catch {
    throw new RefundHttpError(400, "Invalid JSON body");
  }
}

export async function handleRefundResolution(
  req: Request,
  decision: RefundDecision,
  deps: RefundResolutionDependencies,
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "POST required" }, 405);
  }

  try {
    const body = await requestBody(req);
    const refundId = Number(body.refundId);
    if (!Number.isSafeInteger(refundId) || refundId <= 0) {
      throw new RefundHttpError(400, "A valid refundId is required");
    }

    const note = typeof body.note === "string" ? body.note.trim() : "";
    const actorUserId = await deps.authenticate(req);
    const resolution = await deps.resolve({
      refundId,
      decision,
      note,
      actorUserId,
    });

    let notificationSent = resolution.notificationSent;
    let notificationWarning: string | undefined;
    if (!resolution.alreadyResolved && !notificationSent) {
      try {
        await deps.notify(resolution, note);
        await deps.markNotificationSent(refundId);
        notificationSent = true;
      } catch (error) {
        notificationWarning = error instanceof Error
          ? error.message
          : "Customer notification failed";
      }
    }

    return json({
      ...resolution,
      notificationSent,
      ...(notificationWarning ? { notificationWarning } : {}),
    });
  } catch (error) {
    const status = error instanceof RefundHttpError ? error.status : 500;
    const message = error instanceof Error ? error.message : "Refund failed";
    return json({ error: message }, status);
  }
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>'"]/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "'": "&#39;",
    '"': "&quot;",
  })[character]!);
}

export function refundEmailHtml(
  decision: RefundDecision,
  resolution: RefundResolution,
  note: string,
): string {
  const approved = decision === "approved";
  const title = approved
    ? "Loyalty Balance Credit Approved"
    : "Loyalty Balance Credit Request Denied";
  const outcome = approved
    ? `$${resolution.amount.toFixed(2)} has been added to your Clean Stream loyalty balance. No money was returned to your original payment method.`
    : `Your request for a $${resolution.amount.toFixed(2)} Clean Stream loyalty balance credit was not approved.`;
  const safeNote = note ? `<p><strong>Note:</strong> ${escapeHtml(note)}</p>` : "";
  return `<h2>${title}</h2>
    <p>Transaction <strong>${resolution.transactionId}</strong></p>
    <p>${outcome}</p>
    ${safeNote}`;
}
