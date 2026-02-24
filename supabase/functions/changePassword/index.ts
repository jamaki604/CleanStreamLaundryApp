import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const { code, password } = await req.json();
    if (!code || !password) {
      return new Response("Missing code or password", { status: 400 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data, error } = await supabase.auth.exchangeCodeForSession(code);
    if (error || !data?.user) {
      return new Response("Invalid or expired code", { status: 401 });
    }

    const { error: updateError } = await supabase.auth.admin.updateUserById(
      data.user.id,
      { password },
    );
    if (updateError) {
      return new Response("Failed to update password", { status: 500 });
    }

    return new Response("Password updated", { status: 200 });
  } catch {
    return new Response("Bad Request", { status: 400 });
  }
});