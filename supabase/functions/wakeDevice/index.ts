import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "*",
  "Access-Control-Max-Age": "86400",
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    // Parse request body
    let body;
    try {
      const text = await req.text();
      body = text ? JSON.parse(text) : {};
    } catch (e) {
      return new Response(
        JSON.stringify({ error: "Invalid JSON body" }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders,
          },
        }
      );
    }

    const deviceId = body.deviceId;

    // Validate deviceId
    if (!deviceId) {
      return new Response(
        JSON.stringify({ 
          error: "deviceId is required",
          receivedBody: body 
        }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders,
          },
        }
      );
    }

    // Simulate ping with 95% success rate
    const random = Math.random();
    const success = random < 0.95;

    // Simulate network delay (50-200ms)
    const delay = Math.floor(Math.random() * 150) + 50;
    await new Promise((resolve) => setTimeout(resolve, delay));

    if (success) {
      return new Response(
        JSON.stringify({
          success: true,
          deviceId,
          message: "Device wake signal sent successfully",
          timestamp: new Date().toISOString(),
          responseTime: `${delay}ms`,
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders,
          },
        }
      );
    } else {
      return new Response(
        JSON.stringify({
          success: false,
          deviceId,
          error: "Device unreachable or timeout",
          timestamp: new Date().toISOString(),
          responseTime: `${delay}ms`,
        }),
        {
          status: 503,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders,
          },
        }
      );
    }
  } catch (error) {
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