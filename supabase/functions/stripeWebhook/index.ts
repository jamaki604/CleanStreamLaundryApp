import { serve } from "https://deno.land/std@0.223.0/http/server.ts";
import Stripe from "npm:stripe@14";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handleStripeWebhook } from "./logic.ts";
import {
  createAdminClient,
  markCortinaCardPaid,
} from "../_shared/cortina.ts";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  const rawBody = await req.text();

  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;
  const admin = createAdminClient();

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

      recordWalletLoad: async (payload) => {
        const { error } = await admin.rpc("record_wallet_load_from_stripe", {
          target_user_id: payload.user_id,
          amount_cents: payload.amount_cents,
          stripe_payment_intent_id: payload.stripe_payment_intent_id ?? null,
          stripe_checkout_session_id: payload.stripe_checkout_session_id ?? null,
          stripe_charge_id: payload.stripe_charge_id ?? null,
          stripe_event_id: payload.stripe_event_id ?? null,
        });

        if (error) {
          throw new Error(error.message);
        }
      },

      recordCortinaPayment: async (payload) => {
        await markCortinaCardPaid(
          {
            eventId: payload.event_id,
            sessionId: payload.session_id,
            amountCents: payload.amount_cents,
            paymentIntentId: payload.stripe_payment_intent_id,
            checkoutSessionId: payload.stripe_checkout_session_id,
            chargeId: payload.stripe_charge_id,
          },
          { admin, stripe },
        );
      },
    }
  );

  return new Response(result.body, { status: result.status });
});
