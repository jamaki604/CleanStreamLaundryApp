import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface DenyRefundParams {
  userId: string;
  transactionId: string;
  amount: string;
}

export interface DenyRefundDeps {
  supabase: SupabaseClient;
  sendEmail: (to: string, transactionId: string, amount: string) => Promise<void>;
}

export function extractParams(url: URL): DenyRefundParams {
  const userId = url.searchParams.get("user_id");
  const transactionId = url.searchParams.get("transaction_id");
  const amount = url.searchParams.get("amount");

  if (!userId || !transactionId || !amount) {
    throw new Error("Missing params");
  }

  return { userId, transactionId, amount };
}

export async function denyRefundInDb(
  supabase: SupabaseClient,
  transactionId: string
): Promise<void> {
  const { error } = await supabase
    .from("Refunds")
    .update({ status: "denied" })
    .eq("transaction_id", transactionId);

  if (error) {
    throw new Error(`Refund update error: ${error.message}`);
  }
}

export async function getUserEmail(
  supabase: SupabaseClient,
  userId: string
): Promise<string> {
  const {
    data: { user },
    error,
  } = await supabase.auth.admin.getUserById(userId);

  if (error || !user) {
    throw new Error(`User not found: ${error?.message ?? "No data"}`);
  }

  if (!user.email) {
    throw new Error("User email not found");
  }

  return user.email;
}

export async function sendDenialEmail(
  resendApiKey: string,
  to: string,
  transactionId: string,
  amount: string
): Promise<void> {
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: "refund@updates.cleanstreamlaundry.com",
      to,
      subject: "Refund Request Denied",
      html: `
        <h2>Refund Request Denied</h2>
        <p>Unfortunately, your refund request for transaction <strong>${transactionId}</strong> has been denied.</p>
        <p><strong>Amount:</strong> $${amount}</p>
        <p>If you have questions about this decision, please contact support.</p>
      `,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Email send failed: ${errorText}`);
  }
}

export async function handleDenyRefund(
  req: Request,
  deps: DenyRefundDeps
): Promise<Response> {
  const url = new URL(req.url);
  const { userId, transactionId, amount } = extractParams(url);

  await denyRefundInDb(deps.supabase, transactionId);

  const userEmail = await getUserEmail(deps.supabase, userId);

  await deps.sendEmail(userEmail, transactionId, amount);

  const html = `Refund Denied
    The refund request has been denied and
    the customer has been notified via email.
    Transaction: ${transactionId}
    Amount: $${amount}
  `;

  return new Response(html, {
    status: 200,
    headers: { "Content-Type": "text/html" },
  });
}