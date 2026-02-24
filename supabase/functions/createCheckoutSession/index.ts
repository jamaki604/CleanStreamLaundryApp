import Stripe from "npm:stripe@^14.0.0";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY"), {
  apiVersion: "2024-06-20"
});
serve(async (req)=>{
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey, x-client-info"
  };
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers
    });
  }
  try {
    const { amount } = await req.json();
    // ✅ Proper token extraction for Edge Functions
    const authHeader = req.headers.get("Authorization") || "";
    const token = authHeader.replace("Bearer ", "");
    const supabase = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_ANON_KEY"), {
      global: {
        headers: token ? {
          Authorization: `Bearer ${token}`
        } : {}
      }
    });
    // ✅ Correct Edge Function way to get current user
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      console.error("Auth error:", userError);
      return new Response("Unauthorized", {
        status: 401
      });
    }
    // --- Stripe Checkout ---
    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      payment_method_types: [
        "card"
      ],
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: "Laundry Service"
            },
            unit_amount: amount
          },
          quantity: 1
        }
      ],
      metadata: {
        user_id: user.id
      },
      success_url: "http://localhost:8080/homaPage",
      cancel_url: "http://localhost:8080/homePage"
    });
    return new Response(JSON.stringify({
      url: session.url,
      session_id: session.id
    }), {
      headers: {
        ...headers,
        "Content-Type": "application/json"
      }
    });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({
      error: err.message
    }), {
      status: 400,
      headers
    });
  }
});
