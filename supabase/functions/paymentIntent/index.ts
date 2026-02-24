import Stripe from "npm:stripe";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
});

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey, x-client-info",
      },
    });
  }

  if (req.method === "POST") {
    try {
      const { amount } = await req.json();

      console.log("Creating PaymentIntent for:", amount); 

      const intent = await stripe.paymentIntents.create({
        amount,
        currency: "usd",
        payment_method_types: ["card"],
      });

      return new Response(
        JSON.stringify({ clientSecret: intent.client_secret }),
        {
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json",
          },
        }
      );
    } catch (err) {
      console.error("Stripe error:", err);
      return new Response(
        JSON.stringify({ error: err.message ?? "Unknown error" }),
        {
          status: 400,
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json",
          },
        }
      );
    }
  }

  return new Response("Method Not Allowed", {
    status: 405,
    headers: { "Access-Control-Allow-Origin": "*" },
  });
});
