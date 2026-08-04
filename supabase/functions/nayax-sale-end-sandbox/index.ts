import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {
  createAdminClient,
  createStripeClient,
} from "../_shared/cortina.ts";
import { handleNayaxCallback } from "../_shared/cortina_callback.ts";

const deps = { admin: createAdminClient(), stripe: createStripeClient() };

Deno.serve(async (req) => {
  try {
    return await handleNayaxCallback(req, "sandbox", deps);
  } catch (error) {
    console.error("nayax-sale-end-sandbox", error);
    return Response.json({
      Status: { Verdict: "Declined", Code: 999, StatusMessage: "Internal error" },
    });
  }
});
