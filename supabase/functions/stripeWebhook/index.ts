import { serve } from "https://deno.land/std@0.223.0/http/server.ts";
import Stripe from "npm:stripe@14";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handleStripeWebhook } from "./logic.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  const rawBody = await req.text();

  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

  const result = await handleStripeWebhook(
    { rawBody, signature },
    {
      verifyAndConstructEvent: async (body, sig) => {
        return await stripe.webhooks.constructEventAsync(
          body,
          sig,
          webhookSecret,
          undefined,
          Stripe.createSubtleCryptoProvider()
        );
      },

      broadcastPaymentSuccess: async (payload) => {
        const supabase = createClient(
          Deno.env.get("SUPABASE_URL")!,
          Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
        );

        await supabase.channel("payments").send({
          type: "broadcast",
          event: "payment_success",
          payload,
        });
      },
    }
  );

  return new Response(result.body, { status: result.status });
});