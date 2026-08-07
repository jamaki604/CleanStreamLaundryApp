import {
  assert,
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  handleRefundResolution,
  RefundHttpError,
  refundEmailHtml,
  type RefundResolution,
  type RefundResolutionDependencies,
} from "./refund_resolution.ts";

const resolution = (overrides: Partial<RefundResolution> = {}): RefundResolution => ({
  success: true,
  alreadyResolved: false,
  refundId: 12,
  transactionId: 44,
  customerId: "customer-1",
  amount: 2.5,
  status: "approved",
  notificationSent: false,
  ...overrides,
});

function request(body: unknown): Request {
  return new Request("http://localhost/approveRefund", {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: "Bearer test" },
    body: JSON.stringify(body),
  });
}

function dependencies(overrides: Partial<RefundResolutionDependencies> = {}) {
  const calls = { notify: 0, mark: 0 };
  const deps: RefundResolutionDependencies = {
    authenticate: async () => "admin-1",
    resolve: async ({ decision }) => resolution({ status: decision }),
    notify: async () => { calls.notify += 1; },
    markNotificationSent: async () => { calls.mark += 1; },
    ...overrides,
  };
  return { calls, deps };
}

Deno.test("refund resolution notifies only after the database succeeds", async () => {
  const { calls, deps } = dependencies();
  const response = await handleRefundResolution(
    request({ refundId: 12, note: "Machine failed" }),
    "approved",
    deps,
  );
  const body = await response.json();

  assertEquals(response.status, 200);
  assertEquals(body.status, "approved");
  assertEquals(body.notificationSent, true);
  assertEquals(calls, { notify: 1, mark: 1 });
});

Deno.test("an idempotent retry does not send a duplicate notification", async () => {
  const { calls, deps } = dependencies({
    resolve: async () => resolution({ alreadyResolved: true }),
  });
  const response = await handleRefundResolution(
    request({ refundId: 12 }),
    "approved",
    deps,
  );

  assertEquals(response.status, 200);
  assertEquals(calls, { notify: 0, mark: 0 });
});

Deno.test("notification failure does not hide a completed refund", async () => {
  const { calls, deps } = dependencies({
    notify: async () => {
      calls.notify += 1;
      throw new Error("Email unavailable");
    },
  });
  const response = await handleRefundResolution(
    request({ refundId: 12 }),
    "approved",
    deps,
  );
  const body = await response.json();

  assertEquals(response.status, 200);
  assertEquals(body.success, true);
  assertEquals(body.notificationSent, false);
  assertStringIncludes(body.notificationWarning, "Email unavailable");
  assertEquals(calls, { notify: 1, mark: 0 });
});

Deno.test("invalid refund identifiers are rejected before authentication", async () => {
  const { deps } = dependencies();
  const response = await handleRefundResolution(
    request({ refundId: "R12" }),
    "denied",
    deps,
  );
  assertEquals(response.status, 400);
});

Deno.test("authentication and authorization errors reach the caller", async () => {
  const { deps } = dependencies({
    authenticate: async () => {
      throw new RefundHttpError(403, "Owner or Admin access required");
    },
  });
  const response = await handleRefundResolution(
    request({ refundId: 12 }),
    "denied",
    deps,
  );
  const body = await response.json();

  assertEquals(response.status, 403);
  assertEquals(body.error, "Owner or Admin access required");
});

Deno.test("refund email escapes administrator notes", () => {
  const html = refundEmailHtml(
    "approved",
    resolution(),
    '<script>alert("x")</script>',
  );
  assert(!html.includes("<script>"));
  assertStringIncludes(html, "&lt;script&gt;");
});
