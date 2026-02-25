import { getPaymentStatusLogic, PaymentDeps, PaymentParams } from "./logic.ts";
import Stripe from "npm:stripe@^14.0.0";

const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
if (!stripeKey) throw new Error("Missing STRIPE_SECRET_KEY env var");

const stripe = new Stripe(stripeKey, { apiVersion: "2023-10-16" });

export async function getPaymentStatus(req: Request) {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Content-Type": "application/json",
  };

  if (req.method === "OPTIONS") return new Response(null, { headers });

  try {
    const { session_id } = await req.json();

    const deps: PaymentDeps = {
      retrieveSession: (id) => stripe.checkout.sessions.retrieve(id),
    };

    const result = await getPaymentStatusLogic({ sessionId: session_id }, deps);

    return new Response(JSON.stringify({ status: result }), { headers });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), { status: 400, headers });
  }
}