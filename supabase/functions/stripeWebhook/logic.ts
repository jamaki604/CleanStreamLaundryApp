export interface StripeEvent {
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
  }
  
  export async function handleStripeWebhook(
    params: {
      rawBody: string;
      signature: string | null;
    },
    deps: Dependencies
  ) {
    const { rawBody, signature } = params;
    const { verifyAndConstructEvent, broadcastPaymentSuccess } = deps;
  
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
  
      await broadcastPaymentSuccess({
        user_id: session.metadata?.user_id,
        amount: session.amount_total,
      });
    }
  
    return { status: 200, body: "OK" };
  }