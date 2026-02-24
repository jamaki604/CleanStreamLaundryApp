import Stripe from "npm:stripe@^14.0.0";
const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY"), {
  apiVersion: "2024-06-20"
});
export default (async (req)=>{
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Content-Type": "application/json"
  };
  // Handle preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers
    });
  }
  try {
    const { session_id } = await req.json();
    console.log(session_id);
    if (!session_id) {
      return new Response(JSON.stringify({
        error: "Missing session_id"
      }), {
        status: 400,
        headers
      });
    }
    const session = await stripe.checkout.sessions.retrieve(session_id);
    return new Response(JSON.stringify({
      status: session.payment_status
    }), {
      headers
    });
  } catch (err) {
    return new Response(JSON.stringify({
      error: err.message
    }), {
      status: 400,
      headers
    });
  }
});
