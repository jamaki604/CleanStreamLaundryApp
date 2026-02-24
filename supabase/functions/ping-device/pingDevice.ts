import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const SUPABASE_URL = "https://dnuuhupoxjtwqzaqylvb.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRudXVodXBveGp0d3F6YXF5bHZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3MDIzOTMsImV4cCI6MjA3NTI3ODM5M30.W6CvYhQlRcsKV6NJLU99aAI4-woHpYZ63hZbD4WeTW4";
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
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
