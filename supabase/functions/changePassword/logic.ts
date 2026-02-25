export interface ResetPasswordDeps {
  exchangeCode: (code: string) => Promise<{ userId: string }>;
  updatePassword: (userId: string, password: string) => Promise<void>;
}

export interface ResetPasswordParams {
  code: string;
  password: string;
}

export async function resetPassword(
  params: ResetPasswordParams,
  deps: ResetPasswordDeps
) {
  const { code, password } = params;

  if (!code || !password) {
    throw new Error("Missing code or password");
  }

  const { userId } = await deps.exchangeCode(code);

  if (!userId) {
    throw new Error("Invalid or expired code");
  }

  await deps.updatePassword(userId, password);

  return { success: true, userId };
}