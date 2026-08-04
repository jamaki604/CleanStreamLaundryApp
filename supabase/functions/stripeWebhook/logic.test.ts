import {
    handleStripeWebhook,
  } from "./logic.ts";
  
  import {
    assertEquals,
    assert,
  } from "https://deno.land/std@0.224.0/testing/asserts.ts";
  
  
  function createDeps(options?: {
    eventType?: string;
    shouldThrow?: boolean;
  }) {
    let broadcastCalled = false;
    let broadcastPayload: any = null;
  
    return {
      deps: {
        verifyAndConstructEvent: async () => {
          if (options?.shouldThrow) {
            throw new Error("Invalid signature");
          }
  
          return {
            type: options?.eventType ?? "checkout.session.completed",
            data: {
              object: {
                metadata: { user_id: "user123" },
                amount_total: 5000,
              },
            },
          };
        },
  
        broadcastPaymentSuccess: async (payload: any) => {
          broadcastCalled = true;
          broadcastPayload = payload;
        },
      },
  
      getBroadcastInfo: () => ({
        broadcastCalled,
        broadcastPayload,
      }),
    };
  }

  
  Deno.test("returns 400 if signature missing", async () => {
    const { deps } = createDeps();
  
    const result = await handleStripeWebhook(
      { rawBody: "{}", signature: null },
      deps
    );
  
    assertEquals(result.status, 400);
    assertEquals(result.body, "No signature");
  });
  
  Deno.test("returns 400 if verification fails", async () => {
    const { deps } = createDeps({ shouldThrow: true });
  
    const result = await handleStripeWebhook(
      { rawBody: "{}", signature: "sig" },
      deps
    );
  
    assertEquals(result.status, 400);
    assert(result.body.includes("Invalid signature"));
  });
  
  Deno.test("broadcasts on checkout.session.completed", async () => {
    const { deps, getBroadcastInfo } = createDeps();
  
    const result = await handleStripeWebhook(
      { rawBody: "{}", signature: "sig" },
      deps
    );
  
    const { broadcastCalled, broadcastPayload } =
      getBroadcastInfo();
  
    assertEquals(result.status, 200);
    assertEquals(broadcastCalled, true);
    assertEquals(broadcastPayload.user_id, "user123");
    assertEquals(broadcastPayload.amount, 5000);
  });
  
  Deno.test("does not broadcast for other event types", async () => {
    const { deps, getBroadcastInfo } = createDeps({
      eventType: "payment.failed",
    });
  
    const result = await handleStripeWebhook(
      { rawBody: "{}", signature: "sig" },
      deps
    );
  
    const { broadcastCalled } = getBroadcastInfo();
  
    assertEquals(result.status, 200);
    assertEquals(broadcastCalled, false);
  });

  Deno.test("routes Cortina PaymentIntent success to vend orchestration", async () => {
    let captured: any = null;
    const result = await handleStripeWebhook(
      { rawBody: "{}", signature: "sig" },
      {
        verifyAndConstructEvent: async () => ({
          id: "evt_cortina",
          type: "payment_intent.succeeded",
          data: {
            object: {
              id: "pi_cortina",
              amount_received: 450,
              latest_charge: "ch_cortina",
              metadata: {
                purpose: "cortina_vend",
                cortina_session_id: "vend-123",
              },
            },
          },
        }),
        broadcastPaymentSuccess: async () => {},
        recordCortinaPayment: async (payload) => {
          captured = payload;
        },
      },
    );

    assertEquals(result.status, 200);
    assertEquals(captured, {
      event_id: "evt_cortina",
      session_id: "vend-123",
      amount_cents: 450,
      stripe_payment_intent_id: "pi_cortina",
      stripe_charge_id: "ch_cortina",
    });
  });
