import Stripe from "npm:stripe@^14.0.0";
import { serve } from "https://deno.land/std/http/server.ts";
import { handleCheckPaymentResult } from "./logic.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
});

serve(async (req) => {
  try {
    const body = await req.json();

    const result = await handleCheckPaymentResult(body, {
      retrieveSession: async (sessionId: string) => {
        return await stripe.checkout.sessions.retrieve(sessionId);
      },
    });

    return new Response(JSON.stringify(result.body), {
      status: result.status,
      headers: { "Content-Type": "application/json" },
    });
  } catch {
    return new Response(
      JSON.stringify({ error: "Bad Request" }),
      { status: 400 }
    );
  }
});