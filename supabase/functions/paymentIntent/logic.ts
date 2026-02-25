import Stripe from "npm:stripe";

export interface PaymentIntentDeps {
  stripe: Stripe;
}

export interface PaymentIntentResult {
  clientSecret: string | null;
}

export function validateAmount(amount: unknown): number {
  if (amount === undefined || amount === null) {
    throw new Error("Missing amount");
  }
  if (typeof amount !== "number" || !Number.isInteger(amount) || amount <= 0) {
    throw new Error("Invalid amount: must be a positive integer (cents)");
  }
  return amount;
}

export async function createPaymentIntent(
  stripe: Stripe,
  amount: number
): Promise<PaymentIntentResult> {
  const intent = await stripe.paymentIntents.create({
    amount,
    currency: "usd",
    payment_method_types: ["card"],
  });

  return { clientSecret: intent.client_secret };
}

export async function handleCreatePaymentIntent(
  req: Request,
  deps: PaymentIntentDeps
): Promise<Response> {
  const body = await req.json();
  const amount = validateAmount(body?.amount);
  const result = await createPaymentIntent(deps.stripe, amount);

  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}