import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { handleExchangeCode } from "./logic.ts";

serve(async (req) => {
  try {
    const body = await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const result = await handleExchangeCode(body, {
      exchangeCodeForSession: async (code: string) => {
        const { data, error } =
          await supabase.auth.exchangeCodeForSession(code);

        if (error) return {};
        return { user: data?.user };
      },
    });

    return new Response(result.body, { status: result.status });

  } catch {
    return new Response("Bad Request", { status: 400 });
  }
});