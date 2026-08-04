import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {
  CORS_HEADERS,
  createAdminClient,
  createStripeClient,
  errorResponse,
} from "../_shared/cortina.ts";
import { handleCortinaVend } from "./logic.ts";

const admin = createAdminClient();
const stripe = createStripeClient();

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }
  try {
    return await handleCortinaVend(req, { admin, stripe });
  } catch (error) {
    console.error("cortina-vend", error);
    return errorResponse(error);
  }
});
