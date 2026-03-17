import {
    handleExchangeCode,
  } from "./logic.ts";
  
  import {
    assertEquals,
  } from "https://deno.land/std@0.224.0/testing/asserts.ts";
  

  function createDeps(options?: {
    user?: any;
  }) {
    return {
      exchangeCodeForSession: async (_code: string) => {
        return options?.user ? { user: options.user } : {};
      },
    };
  }

  
  Deno.test("returns 400 if code missing", async () => {
    const result = await handleExchangeCode({}, createDeps());
  
    assertEquals(result.status, 400);
    assertEquals(result.body, "Missing code");
  });
  
  Deno.test("returns 401 if no user returned", async () => {
    const result = await handleExchangeCode(
      { code: "abc" },
      createDeps()
    );
  
    assertEquals(result.status, 401);
    assertEquals(result.body, "Invalid or expired code");
  });
  
  Deno.test("returns 200 if user exists", async () => {
    const result = await handleExchangeCode(
      { code: "abc" },
      createDeps({ user: { id: "123" } })
    );
  
    assertEquals(result.status, 200);
    assertEquals(result.body, "OK");
  });
  
  Deno.test("calls dependency with correct code", async () => {
    let capturedCode = "";
  
    const deps = {
      exchangeCodeForSession: async (code: string) => {
        capturedCode = code;
        return { user: { id: "123" } };
      },
    };
  
    await handleExchangeCode({ code: "specialCode" }, deps);
  
    assertEquals(capturedCode, "specialCode");
  });