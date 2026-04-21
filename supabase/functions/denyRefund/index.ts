import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handleDenyRefund, sendDenialEmail } from "./logic.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey, x-client-info",
};


serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: CORS_HEADERS });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const resendKey = Deno.env.get("RESEND_API_KEY");

    if (!supabaseUrl || !serviceKey) {
      return new Response("Server configuration error", {
        status: 500,
        headers: CORS_HEADERS,
      });
    }

    const supabase = createClient(supabaseUrl, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const response = await handleDenyRefund(req, {
      supabase,
      sendEmail: (to, transactionId, amount, note) =>
        sendDenialEmail(resendKey!, to, transactionId, amount, note),
    });

    return new Response(response.body, {
      status: response.status,
      headers: { ...CORS_HEADERS, ...Object.fromEntries(response.headers) },
    });
  } catch (e) {
    const err = e instanceof Error ? e : new Error(String(e));

    const statusMap: Record<string, number> = {
      "Missing params": 400,
      "User email not found": 404,
    };
    const status =
      err.message.startsWith("User not found") ? 404
      : err.message.startsWith("Refund update error") ? 500
      : statusMap[err.message] ?? 500;

    return new Response(`Error: ${err.message}`, { status, headers: CORS_HEADERS });
  }
});