import {
    handleCheckPaymentResult,
  } from "./logic.ts";
  
  import {
    assertEquals,
  } from "https://deno.land/std@0.224.0/testing/asserts.ts";
  
  
  function createDeps(options?: {
    paymentStatus?: string;
    shouldThrow?: boolean;
  }) {
    let capturedSessionId = "";
  
    return {
      deps: {
        retrieveSession: async (sessionId: string) => {
          capturedSessionId = sessionId;
  
          if (options?.shouldThrow) {
            throw new Error("Stripe error");
          }
  
          return {
            payment_status: options?.paymentStatus ?? "unpaid",
          };
        },
      },
      getCapturedSessionId: () => capturedSessionId,
    };
  }
  
  
  Deno.test("returns 400 if session_id missing", async () => {
    const { deps } = createDeps();
  
    const result = await handleCheckPaymentResult({}, deps);
  
    assertEquals(result.status, 400);
    assertEquals(result.body.error, "Missing session_id");
  });
  
  Deno.test("returns paid: true when payment_status is paid", async () => {
    const { deps } = createDeps({ paymentStatus: "paid" });
  
    const result = await handleCheckPaymentResult(
      { session_id: "sess_123" },
      deps
    );
  
    assertEquals(result.status, 200);
    assertEquals(result.body.paid, true);
  });
  
  Deno.test("returns paid: false when payment_status is not paid", async () => {
    const { deps } = createDeps({ paymentStatus: "unpaid" });
  
    const result = await handleCheckPaymentResult(
      { session_id: "sess_123" },
      deps
    );
  
    assertEquals(result.status, 200);
    assertEquals(result.body.paid, false);
  });
  
  Deno.test("calls retrieveSession with correct session_id", async () => {
    const { deps, getCapturedSessionId } = createDeps();
  
    await handleCheckPaymentResult(
      { session_id: "sess_abc" },
      deps
    );
  
    assertEquals(getCapturedSessionId(), "sess_abc");
  });
  
  Deno.test("returns 400 if Stripe throws", async () => {
    const { deps } = createDeps({ shouldThrow: true });
  
    const result = await handleCheckPaymentResult(
      { session_id: "sess_123" },
      deps
    );
  
    assertEquals(result.status, 400);
    assertEquals(result.body.error, "Stripe error");
  });