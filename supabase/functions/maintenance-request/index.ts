import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    const body = await req.json();
    
    const { user_id, category, description, image, location } = body;

    console.log(`Processing Maintenance Request for User: ${user_id} at Location: ${location}`);

    if (!user_id || !category || !description || !location) {
      console.error("Missing required fields in request body.");
      return new Response(
        JSON.stringify({ error: "Missing required fields: user_id, category, description, or location" }),
        { 
          status: 400, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    const { data, error: dbError } = await supabase
      .from('Maintenance')
      .insert([
        { 
          user_id: user_id, 
          category: category, 
          description: description, 
          location: location,
          image_data: image, 
          created_at: new Date().toISOString()
        }
      ])
      .select();

    if (dbError) {
      console.error(`Database Error: ${dbError.message}`);
      return new Response(
        JSON.stringify({ error: "Database save failed", details: dbError.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    return new Response(
      JSON.stringify({ success: true, message: "Request logged", record: data }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );

  } catch (err: any) {
    console.error(`Global Handler Error: ${err.message}`);
    return new Response(
      JSON.stringify({ error: "Internal Server Error", message: err.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});