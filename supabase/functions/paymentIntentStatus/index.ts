 import Stripe from "npm:stripe";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handlePaymentIntentStatus } from "./logic.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "Content-Type, Authorization, apikey, x-client-info",
};

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
});

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  if (req.method !== "POST") {
    return new Response("Method Not Allowed", {
      status: 405,
      headers: CORS_HEADERS,
    });
  }

  try {
    const response = await handlePaymentIntentStatus(req, {
      stripe,
      supabaseAdmin,
    });

    return new Response(response.body, {
      status: response.status,
      headers: { ...CORS_HEADERS, ...Object.fromEntries(response.headers) },
    });
  } catch (err) {
    const error = err instanceof Error ? err : new Error(String(err));
    return new Response(
      JSON.stringify({ error: error.message ?? "Unknown error" }),
      {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      }
    );
  }
});
