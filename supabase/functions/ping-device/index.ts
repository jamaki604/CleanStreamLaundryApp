import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handleMachineRequest } from "./logic.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
const supabase = createClient(supabaseUrl, anonKey);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "*",
  "Access-Control-Max-Age": "86400",
};

async function getMachineStatusFromSupabase(deviceId: string) {
  try {
    const { data, error } = await supabase
      .from("Machines")
      .select("Status")
      .eq("id", deviceId)
      .single();

    if (error || !data) return "error";

    const status = data.Status?.toLowerCase();

    const valid = ["idle", "in-use", "offline", "error"];

    return valid.includes(status) ? status : "offline";
  } catch {
    return "error";
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const text = await req.text();
    const body = text ? JSON.parse(text) : {};

    const result = await handleMachineRequest(body, {
      getMachineStatus: getMachineStatusFromSupabase,
      random: Math.random,
      delay: (ms: number) =>
        new Promise((resolve) => setTimeout(resolve, ms)),
    });

    return new Response(JSON.stringify(result.body), {
      status: result.status,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders,
      },
    });
  } catch (error: any) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Internal server error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders,
        },
      }
    );
  }
});