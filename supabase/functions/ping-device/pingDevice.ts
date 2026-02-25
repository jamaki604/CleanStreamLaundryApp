import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";


const supabaseUrl = Deno.env.get("SUPABASE_URL");
const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
const supabase = createClient(supabaseUrl, anonKey);
async function getMachineStatusFromSupabase(deviceId) {
  try {
    const { data, error } = await supabase.from('Machines').select('Status').eq('id', deviceId).single();
    console.log("Supabase data:", data);
    console.log("Supabase error:", error);
    if (error || !data) {
      return 'error';
    }
    const status = data.Status?.toLowerCase();
    console.log("status: ", status);
    const validStatuses = [
      'idle',
      'in-use',
      'offline',
      'error'
    ];
    return validStatuses.includes(status) ? status : 'offline';
  } catch (e) {
    console.error("Supabase fetch error:", e);
    return 'error';
  }
}
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "*",
  "Access-Control-Max-Age": "86400"
};
serve(async (req)=>{
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders
    });
  }
  try {
    const text = await req.text();
    const body = text ? JSON.parse(text) : {};
    const deviceId = body.deviceId;
    if (!deviceId) {
      return new Response(JSON.stringify({
        error: "deviceId is required",
        receivedBody: body
      }), {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders
        }
      });
    }
    const random = Math.random();
    const success = random < 0.95;
    const delay = Math.floor(Math.random() * 150) + 50;
    await new Promise((resolve)=>setTimeout(resolve, delay));
    const machineStatus = await getMachineStatusFromSupabase(deviceId);
    if (success) {
      return new Response(JSON.stringify({
        success: true,
        deviceId,
        message: machineStatus,
        timestamp: new Date().toISOString(),
        responseTime: `${delay}ms`
      }), {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders
        }
      });
    } else {
      return new Response(JSON.stringify({
        success: false,
        deviceId,
        error: "Device unreachable or timeout",
        timestamp: new Date().toISOString(),
        responseTime: `${delay}ms`
      }), {
        status: 503,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders
        }
      });
    }
  } catch (error) {
    return new Response(JSON.stringify({
      success: false,
      error: error.message || "Internal server error"
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders
      }
    });
  }
});
