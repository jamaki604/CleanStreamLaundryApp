import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "*",
  "Access-Control-Max-Age": "86400"
};
serve(async (req)=>{
  // --- Handle CORS preflight ---
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders
    });
  }
  try {
    // -------------------------------
    // Parse incoming JSON safely
    // -------------------------------
    let body;
    try {
      const text = await req.text();
      body = text ? JSON.parse(text) : {};
    } catch (e) {
      return new Response(JSON.stringify({
        error: "Invalid JSON body"
      }), {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders
        }
      });
    }
    // --------------------------------------------------------
    // Extract expected fields from the body (sent by your app)
    // --------------------------------------------------------
    const username = body.username;
    const userId = body.user_id;
    const transactionId = body.transaction_id;
    const amount = body.amount;
    const description = body.description;
    const userAttempts = body.userAttempts;
    // Validate required fields
    if (!username || !userId || !transactionId || !amount) {
      return new Response(JSON.stringify({
        error: "Missing required fields",
        received: body
      }), {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders
        }
      });
    }
    const approveLink = "https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1/approveRefund" + `?user_id=${userId}&transaction_id=${transactionId}&amount=${amount}`;
    const denyLink = "https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1/denyRefund" + `?user_id=${userId}&transaction_id=${transactionId}&amount=${amount}`;
    // --------------------------------------------------------
    // Build the email HTML
    // --------------------------------------------------------
    const emailBody = `
      <h2>Refund Request Received</h2>
      <p><strong>Name:</strong> ${username}</p>
      <p><strong>User ID:</strong> ${userId}</p>
      <p><strong>Transaction ID:</strong> ${transactionId}</p>
      <p><strong>Amount:</strong> $${amount}</p>
      <p><strong>Reason:</strong> ${description}</p>
      <p><strong>Number of refund attempts:</strong> ${userAttempts}</p>
      <div style="margin-top: 30px; margin-bottom: 30px;">
        <a 
          href="${approveLink}"
          style="display:inline-block; padding:12px 20px; background:#4CAF50; color:white; border-radius:6px; text-decoration:none; margin-right:15px; margin-bottom:10px;"
        >
          Approve Refund
        </a>
        <a 
          href="${denyLink}"
          style="display:inline-block; padding:12px 20px; background:#f44336; color:white; border-radius:6px; text-decoration:none; margin-bottom:10px;"
        >
          Deny Refund
        </a>
      </div>
      <p>&nbsp;</p>
    `;
    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    // --------------------------------------------------------
    // Send email via Resend
    // --------------------------------------------------------
    const emailResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        from: "refund@updates.cleanstreamlaundry.com",
        to: "yoder453@gmail.com",
        subject: `New Refund Request - ${username}`,
        html: emailBody
      })
    });
    const emailData = await emailResponse.json();
    console.log("Resend API response:", emailData);
    return new Response(JSON.stringify({
      success: true,
      resend: emailData
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders
      }
    });
  } catch (error) {
    console.error("Refund email error:", error);
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
