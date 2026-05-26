export interface StripeEvent {
    id?: string;
    type: string;
    data: {
      object: any;
    };
  }
  
  export interface Dependencies {
    verifyAndConstructEvent: (rawBody: string, signature: string) => Promise<StripeEvent>;
    broadcastPaymentSuccess: (payload: {
      user_id?: string;
      amount?: number;
    }) => Promise<void>;
    recordWalletLoad?: (payload: {
      user_id: string;
      amount_cents: number;
      stripe_payment_intent_id?: string | null;
      stripe_checkout_session_id?: string | null;
      stripe_charge_id?: string | null;
      stripe_event_id?: string | null;
    }) => Promise<void>;
  }
  
  export async function handleStripeWebhook(
    params: {
      rawBody: string;
      signature: string | null;
    },
    deps: Dependencies
  ) {
    const { rawBody, signature } = params;
    const { verifyAndConstructEvent, broadcastPaymentSuccess, recordWalletLoad } = deps;
  
    if (!signature) {
      return { status: 400, body: "No signature" };
    }
  
    let event: StripeEvent;
  
    try {
      event = await verifyAndConstructEvent(rawBody, signature);
    } catch (err: any) {
      return {
        status: 400,
        body: `Webhook Error: ${err.message}`,
      };
    }
  
    if (event.type === "checkout.session.completed") {
      const session = event.data.object;
      const purpose = session.metadata?.purpose;
      const userId = session.metadata?.user_id;
      const amount = session.amount_total;

      if (purpose === "wallet_load" && userId && amount) {
        await recordWalletLoad?.({
          user_id: userId,
          amount_cents: amount,
          stripe_payment_intent_id: session.payment_intent,
          stripe_checkout_session_id: session.id,
          stripe_event_id: event.id ?? null,
        });
      }
  
      await broadcastPaymentSuccess({
        user_id: userId,
        amount,
      });
    }

    if (event.type === "payment_intent.succeeded") {
      const paymentIntent = event.data.object;
      const purpose = paymentIntent.metadata?.purpose;
      const userId = paymentIntent.metadata?.user_id;
      const amount = paymentIntent.amount_received ?? paymentIntent.amount;

      if (purpose === "wallet_load" && userId && amount) {
        await recordWalletLoad?.({
          user_id: userId,
          amount_cents: amount,
          stripe_payment_intent_id: paymentIntent.id,
          stripe_charge_id:
            typeof paymentIntent.latest_charge === "string"
              ? paymentIntent.latest_charge
              : paymentIntent.latest_charge?.id ?? null,
          stripe_event_id: event.id ?? null,
        });
      }
    }
  
    return { status: 200, body: "OK" };
  }
