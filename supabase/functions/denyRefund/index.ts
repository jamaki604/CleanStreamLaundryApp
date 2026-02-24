import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey"
};
serve(async (req)=>{
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders
    });
  }
  try {
    const url = new URL(req.url);
    const userId = url.searchParams.get("user_id");
    const transactionId = url.searchParams.get("transaction_id");
    const amount = url.searchParams.get("amount");
    console.log("Deny request - Received params:", {
      userId,
      transactionId,
      amount
    });
    if (!userId || !transactionId || !amount) {
      return new Response("Missing params", {
        status: 400,
        headers: corsHeaders
      });
    }
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const resendKey = Deno.env.get("RESEND_API_KEY");
    if (!supabaseUrl || !serviceKey) {
      return new Response("Server configuration error", {
        status: 500,
        headers: corsHeaders
      });
    }
    // Create Supabase client with service role key
    const supabase = createClient(supabaseUrl, serviceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });
    const { error: refundUpdateError } = await supabase.from("Refunds").update({
      status: "denied"
    }).eq("transaction_id", transactionId);
    if (refundUpdateError) {
      console.error("Refund update error:", refundUpdateError);
      return new Response(`Refund update error: ${refundUpdateError.message}`, {
        status: 500,
        headers: corsHeaders
      });
    }
    console.log("Fetching user email...");
    // Fetch user email from auth
    const { data: { user }, error: userError } = await supabase.auth.admin.getUserById(userId);
    if (userError || !user) {
      console.error("User fetch error:", userError);
      return new Response(`User not found: ${userError?.message || 'No data'}`, {
        status: 404,
        headers: corsHeaders
      });
    }
    const userEmail = user.email;
    if (!userEmail) {
      return new Response("User email not found", {
        status: 404,
        headers: corsHeaders
      });
    }
    console.log("Sending denial email to:", userEmail);
    // Send denial email
    const emailResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        from: "refund@updates.cleanstreamlaundry.com",
        to: userEmail,
        subject: "Refund Request Denied",
        html: `
          <h2>Refund Request Denied</h2>
          <p>Unfortunately, your refund request for transaction <strong>${transactionId}</strong> has been denied.</p>
          <p><strong>Amount:</strong> $${amount}</p>
          <p>If you have questions about this decision, please contact support.</p>
        `
      })
    });
    console.log("Email response status:", emailResponse.status);
    if (!emailResponse.ok) {
      const errorText = await emailResponse.text();
      console.error("Email send failed:", errorText);
    }
    const html = `Refund Denied
      The refund request has been denied and 
      the customer has been notified via email.
      Transaction:${transactionId}
      Amount:$${amount}
    `;
    return new Response(html, {
      headers: {
        "Content-Type": "text/html"
      }
    });
  } catch (e) {
    console.error("Caught error:", e);
    return new Response(`Error: ${e.message}`, {
      status: 500,
      headers: corsHeaders
    });
  }
});
