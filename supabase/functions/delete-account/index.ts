import { serve } from "https://deno.land/std@0.182.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.14.0";
import { handleDeleteUser } from "./logic.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey, x-client-info",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "");

    if (!jwt) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: CORS_HEADERS,
      });
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const body = await req.clone().json();
    const { data: userData, error: userError } = await supabaseAdmin.auth.getUser(jwt);

    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: "Invalid authorization" }), {
        status: 401,
        headers: CORS_HEADERS,
      });
    }

    if (body?.user_id !== userData.user.id) {
      return new Response(JSON.stringify({ error: "Cannot delete another user" }), {
        status: 403,
        headers: CORS_HEADERS,
      });
    }

    const response = await handleDeleteUser(req, { supabaseAdmin });

    return new Response(response.body, {
      status: response.status,
      headers: { ...CORS_HEADERS, ...Object.fromEntries(response.headers) },
    });
  } catch (err) {
    const status = err.message === "Missing user_id" ? 400 : 500;
    return new Response(JSON.stringify({ error: err.message }), {
      status,
      headers: CORS_HEADERS,
    });
  }
});
