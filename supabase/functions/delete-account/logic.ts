import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.14.0";

export interface DeleteUserDeps {
  supabaseAdmin: SupabaseClient;
}

export interface DeleteUserResult {
  success: true;
  data: unknown;
}

export function validateUserId(user_id: unknown): string {
  if (!user_id || typeof user_id !== "string" || user_id.trim() === "") {
    throw new Error("Missing user_id");
  }
  return user_id;
}


export async function deleteUser(
  supabaseAdmin: SupabaseClient,
  user_id: string
): Promise<DeleteUserResult> {
  const { data, error } = await supabaseAdmin.auth.admin.deleteUser(user_id);

  if (error) {
    throw new Error(error.message);
  }

  return { success: true, data };
}

export async function handleDeleteUser(
  req: Request,
  deps: DeleteUserDeps
): Promise<Response> {
  const body = await req.json();
  const user_id = validateUserId(body?.user_id);
  const result = await deleteUser(deps.supabaseAdmin, user_id);

  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}