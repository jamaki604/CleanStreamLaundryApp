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