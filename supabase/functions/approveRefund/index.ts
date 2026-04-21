import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { processRefund } from "./logic.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey, x-client-info",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

let userId: string, transactionId: string, amount: string, note: string;

  try {
    const body = await req.json();
    userId = body.customerId || body.user_id; 
    transactionId = body.id || body.transactionId || body.transaction_id;
    amount = body.amount;
    note = body.note;

    if (!userId || !transactionId || !amount) {
      return new Response(
        JSON.stringify({ error: "Missing required parameters" }),
        { status: 400, headers: corsHeaders }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const resendKey = Deno.env.get("RESEND_API_KEY");

    if (!supabaseUrl || !serviceKey || !resendKey) {
      return new Response("Server configuration error", {
        status: 500,
        headers: corsHeaders,
      });
    }

    const supabase = createClient(supabaseUrl, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const deps = {
      updateRefund: async (transactionId: string, note: string) => {
        const { error } = await supabase
          .from("Refunds")
          .update({ status: "approved", "admin-note": note })
          .eq("transaction_id", transactionId);

        if (error) throw new Error(error.message);
      },

      getUserEmail: async (userId: string) => {
        const { data, error } =
          await supabase.auth.admin.getUserById(userId);

        if (error || !data?.user?.email) {
          throw new Error("User not found");
        }

        return data.user.email;
      },

      incrementLoyalty: async (userId: string, amount: number) => {
        const { error } = await supabase.rpc(
          "increment_loyalty_balance",
          {
            user_id: userId,
            increment_amount: amount,
          }
        );

        if (error) throw new Error(error.message);
      },

      sendEmail: async (
        email: string,
        transactionId: string,
        amount: string,
        note: string
      ) => {
        const response = await fetch(
          "https://api.resend.com/emails",
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${resendKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              from: "refund@updates.cleanstreamlaundry.com",
              to: email,
              subject: "Your Refund Was Approved",
              html: `
                <h2>Refund Approved</h2>
                <p>Your refund for transaction 
                <strong>${transactionId}</strong> was approved.</p>
                <p>$${amount} has been added to your loyalty card.</p>
                <p>${note ? `Note: ${note}` : ""} </p>
              `,
            }),
          }
        );

        if (!response.ok) {
          throw new Error("Failed to send email");
        }
      },
    };

    const result = await processRefund(
      { userId, transactionId, amount, note },
      deps
    );

    return new Response(
      JSON.stringify(result),
      {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders,
        },
      }
    );
  } catch (error) {
    console.log(error);
    return new Response(
      JSON.stringify({ error: error.message }),
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