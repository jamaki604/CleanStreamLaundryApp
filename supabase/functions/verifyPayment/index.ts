import Stripe from "npm:stripe@^14.0.0";
import { serve } from "https://deno.land/std/http/server.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY"), {
  apiVersion: "2024-06-20",
});

serve(async (req) => {
  const { session_id } = await req.json();

  const session = await stripe.checkout.sessions.retrieve(session_id);

  return new Response(JSON.stringify({
    paid: session.payment_status === "paid",
  }), {
    headers: { "Content-Type": "application/json" }
  });
});
