import { assertEquals, assertRejects } from "https://deno.land/std@0.224.0/testing/asserts.ts";
import { getPaymentStatusLogic, PaymentDeps } from "./logic.ts";

Deno.test("returns payment status for valid session", async () => {
  const fakeDeps: PaymentDeps = {
    retrieveSession: async (id) => ({ payment_status: "paid" }),
  };

  const result = await getPaymentStatusLogic({ sessionId: "sess_123" }, fakeDeps);
  assertEquals(result, "paid");
});

Deno.test("throws if sessionId is missing", async () => {
    const fakeDeps: PaymentDeps = {
      retrieveSession: async (id) => ({ payment_status: "paid" }),
    };
  
    await assertRejects(  
      () => getPaymentStatusLogic({ sessionId: "" }, fakeDeps),
      Error,
      "Missing sessionId"
    );
  });