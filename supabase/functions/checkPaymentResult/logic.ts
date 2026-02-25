import Stripe from "npm:stripe@^14.0.0";

export interface PaymentDeps {
  retrieveSession: (sessionId: string) => Promise<{ payment_status: string }>;
}

export interface PaymentParams {
  sessionId: string;
}

export async function getPaymentStatusLogic(
  params: PaymentParams,
  deps: PaymentDeps
) {
  const { sessionId } = params;
  if (!sessionId) throw new Error("Missing sessionId");

  const session = await deps.retrieveSession(sessionId);
  return session.payment_status;
}