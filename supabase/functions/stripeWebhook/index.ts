import { serve } from "https://deno.land/std@0.223.0/http/server.ts";
import Stripe from "npm:stripe@14";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(), // Use fetch-based client for Deno
});

serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  
  if (!signature) {
    console.error("❌ No signature header found");
    return new Response("No signature", { status: 400 });
  }

  const rawBody = await req.text(); // Try text() instead of arrayBuffer()
  
  let event;
  try {
    const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
    
    if (!webhookSecret) {
      console.error("❌ STRIPE_WEBHOOK_SECRET not set");
      return new Response("Configuration error", { status: 500 });
    }

    event = await stripe.webhooks.constructEventAsync(
      rawBody,
      signature,
      webhookSecret,
      undefined,
      Stripe.createSubtleCryptoProvider() // Explicitly use async crypto
    );
    
    console.log("✅ Signature verified:", event.type);
  } catch (err) {
    console.error("❌ Webhook signature verification failed:", err.message);
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    await supabase
      .channel("payments")
      .send({
        type: "broadcast",
        event: "payment_success",
        payload: {
          user_id: session.metadata?.user_id,
          amount: session.amount_total
        }
      });
  }

  return new Response("OK", { status: 200 });
});