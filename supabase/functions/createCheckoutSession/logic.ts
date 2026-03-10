import Stripe from "npm:stripe@^14.0.0";
import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface CheckoutDeps {
  stripe: Stripe;
  supabase: SupabaseClient;
}

export interface CheckoutResult {
  url: string | null;
  session_id: string;
}

export async function getAuthenticatedUser(supabase: SupabaseClient) {
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error || !user) {
    throw new Error("Unauthorized");
  }

  return user;
}

export async function createCheckoutSession(
  stripe: Stripe,
  amount: number,
  userId: string,
  baseUrl = "http://localhost:8080"
): Promise<CheckoutResult> {
  if (!amount || typeof amount !== "number" || amount <= 0) {
    throw new Error("Invalid amount");
  }

  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    payment_method_types: ["card"],
    line_items: [
      {
        price_data: {
          currency: "usd",
          product_data: { name: "Laundry Service" },
          unit_amount: amount,
        },
        quantity: 1,
      },
    ],
    metadata: { user_id: userId },
    success_url: `${baseUrl}/homePage`,
    cancel_url: `${baseUrl}/homePage`,
  });

  return { url: session.url, session_id: session.id };
}


export async function handleCheckout(
  req: Request,
  deps: CheckoutDeps,
  baseUrl?: string
): Promise<Response> {
  const { amount } = await req.json();

  const user = await getAuthenticatedUser(deps.supabase);
  const result = await createCheckoutSession(deps.stripe, amount, user.id, baseUrl);

  return new Response(JSON.stringify(result), {
    headers: { "Content-Type": "application/json" },
  });
}