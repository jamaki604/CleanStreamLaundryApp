export interface StripeSession {
    payment_status?: string;
  }
  
  export interface Dependencies {
    retrieveSession: (sessionId: string) => Promise<StripeSession>;
  }
  
  export async function handleCheckPaymentResult(
    body: any,
    deps: Dependencies
  ) {
    const { retrieveSession } = deps;
  
    const sessionId = body?.session_id;
  
    if (!sessionId) {
      return {
        status: 400,
        body: { error: "Missing session_id" },
      };
    }
  
    try {
      const session = await retrieveSession(sessionId);
  
      return {
        status: 200,
        body: {
          paid: session.payment_status === "paid",
        },
      };
    } catch (err: any) {
      return {
        status: 400,
        body: {
          error: err.message || "Failed to retrieve session",
        },
      };
    }
  }