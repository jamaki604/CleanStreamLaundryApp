export interface Dependencies {
    exchangeCodeForSession: (
      code: string
    ) => Promise<{ user?: any }>;
  }
  
  export async function handleExchangeCode(
    body: any,
    deps: Dependencies
  ) {
    const { exchangeCodeForSession } = deps;
  
    const code = body?.code;
  
    if (!code) {
      return { status: 400, body: "Missing code" };
    }
  
    const result = await exchangeCodeForSession(code);
  
    if (!result?.user) {
      return { status: 401, body: "Invalid or expired code" };
    }
  
    return { status: 200, body: "OK" };
  }