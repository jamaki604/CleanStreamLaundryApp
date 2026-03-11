import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { resetPassword } from "./logic.ts";

serve(async (req) => {
  try {
    const { code, password } = await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const result = await resetPassword(
      { code, password },
      {
        exchangeCode: async (code) => {
          const { data, error } = await supabase.auth.exchangeCodeForSession(code);
          if (error || !data?.user) return { userId: "" };
          return { userId: data.user.id };
        },
        updatePassword: async (userId, password) => {
          const { error } = await supabase.auth.admin.updateUserById(userId, { password });
          if (error) throw error;
        },
      }
    );

    return new Response("Password updated", { status: 200 });
  } catch (e) {
    return new Response(e.message || "Bad Request", { status: 400 });
  }
});