import {
    assertEquals,
    assertRejects,
  } from "https://deno.land/std@0.168.0/testing/asserts.ts";
  import {
    extractParams,
    denyRefundInDb,
    getUserEmail,
    handleDenyRefund,
  } from "./logic.ts";
  
  function makeUrl(params: Record<string, string>) {
    const url = new URL("http://localhost/deny-refund");
    for (const [k, v] of Object.entries(params)) {
      url.searchParams.set(k, v);
    }
    return url;
  }
  
  function makeFullUrl(overrides: Partial<Record<"user_id" | "transaction_id" | "amount", string>> = {}) {
    return makeUrl({
      user_id: "user-123",
      transaction_id: "txn-abc",
      amount: "25.00",
      ...overrides,
    });
  }
  
  function makeSupabaseMock(overrides: {
    updateError?: { message: string } | null;
    user?: { id: string; email?: string } | null;
    userError?: { message: string } | null;
  } = {}) {
    return {
      from: (_table: string) => ({
        update: (_data: unknown) => ({
          eq: (_col: string, _val: string) =>
            Promise.resolve({ error: overrides.updateError ?? null }),
        }),
      }),
      auth: {
        admin: {
          getUserById: (_id: string) =>
            Promise.resolve({
              data: { user: overrides.user !== undefined ? overrides.user : { id: "user-123", email: "user@example.com" } },
              error: overrides.userError ?? null,
            }),
        },
      },
    } as any;
  }
  
  function makeRequest(url: URL) {
    return new Request(url.toString(), { method: "GET" });
  }
  
  Deno.test("extractParams — returns all three params when present", () => {
    const url = makeFullUrl();
    const params = extractParams(url);
  
    assertEquals(params.userId, "user-123");
    assertEquals(params.transactionId, "txn-abc");
    assertEquals(params.amount, "25.00");
  });
  
  Deno.test("extractParams — throws when user_id is missing", () => {
    const url = makeUrl({ transaction_id: "txn-abc", amount: "25.00" });
    try {
      extractParams(url);
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing params");
    }
  });
  
  Deno.test("extractParams — throws when transaction_id is missing", () => {
    const url = makeUrl({ user_id: "user-123", amount: "25.00" });
    try {
      extractParams(url);
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing params");
    }
  });
  
  Deno.test("extractParams — throws when amount is missing", () => {
    const url = makeUrl({ user_id: "user-123", transaction_id: "txn-abc" });
    try {
      extractParams(url);
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing params");
    }
  });
  
  Deno.test("extractParams — throws when all params are missing", () => {
    const url = new URL("http://localhost/deny-refund");
    try {
      extractParams(url);
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing params");
    }
  });
  
  Deno.test("denyRefundInDb — resolves without error on success", async () => {
    const supabase = makeSupabaseMock();
    // should not throw
    await denyRefundInDb(supabase, "txn-abc");
  });
  
  Deno.test("denyRefundInDb — throws with prefixed message on Supabase error", async () => {
    const supabase = makeSupabaseMock({ updateError: { message: "row not found" } });
  
    await assertRejects(
      () => denyRefundInDb(supabase, "txn-abc"),
      Error,
      "Refund update error: row not found"
    );
  });
  
  Deno.test("denyRefundInDb — passes correct transaction_id to Supabase", async () => {
    let capturedVal: string | undefined;
    const supabase = {
      from: (_table: string) => ({
        update: (_data: unknown) => ({
          eq: (_col: string, val: string) => {
            capturedVal = val;
            return Promise.resolve({ error: null });
          },
        }),
      }),
    } as any;
  
    await denyRefundInDb(supabase, "txn-xyz");
    assertEquals(capturedVal, "txn-xyz");
  });
  
  Deno.test("getUserEmail — returns email on valid user", async () => {
    const supabase = makeSupabaseMock({ user: { id: "user-123", email: "user@example.com" } });
  
    const email = await getUserEmail(supabase, "user-123");
    assertEquals(email, "user@example.com");
  });
  
  Deno.test("getUserEmail — throws when user is null", async () => {
    const supabase = makeSupabaseMock({ user: null });
  
    await assertRejects(
      () => getUserEmail(supabase, "ghost"),
      Error,
      "User not found"
    );
  });
  
  Deno.test("getUserEmail — throws when Supabase returns an error", async () => {
    const supabase = makeSupabaseMock({ userError: { message: "JWT invalid" }, user: null });
  
    await assertRejects(
      () => getUserEmail(supabase, "user-123"),
      Error,
      "User not found: JWT invalid"
    );
  });
  
  Deno.test("getUserEmail — throws when user has no email", async () => {
    const supabase = makeSupabaseMock({ user: { id: "user-123" } }); // no email field
  
    await assertRejects(
      () => getUserEmail(supabase, "user-123"),
      Error,
      "User email not found"
    );
  });
  
  Deno.test("handleDenyRefund — returns 200 with confirmation HTML on success", async () => {
    const req = makeRequest(makeFullUrl());
    const sendEmail = (_to: string, _txn: string, _amt: string) => Promise.resolve();
  
    const res = await handleDenyRefund(req, {
      supabase: makeSupabaseMock(),
      sendEmail,
    });
    const body = await res.text();
  
    assertEquals(res.status, 200);
    assertEquals(body.includes("txn-abc"), true);
    assertEquals(body.includes("25.00"), true);
  });
  
  Deno.test("handleDenyRefund — calls sendEmail with correct args", async () => {
    const req = makeRequest(makeFullUrl());
    let capturedArgs: [string, string, string] | undefined;
  
    await handleDenyRefund(req, {
      supabase: makeSupabaseMock(),
      sendEmail: (to, txn, amt) => {
        capturedArgs = [to, txn, amt];
        return Promise.resolve();
      },
    });
  
    assertEquals(capturedArgs, ["user@example.com", "txn-abc", "25.00"]);
  });
  
  Deno.test("handleDenyRefund — throws Missing params when query params absent", async () => {
    const req = new Request("http://localhost/deny-refund", { method: "GET" });
  
    await assertRejects(
      () => handleDenyRefund(req, {
        supabase: makeSupabaseMock(),
        sendEmail: () => Promise.resolve(),
      }),
      Error,
      "Missing params"
    );
  });
  
  Deno.test("handleDenyRefund — throws when DB update fails", async () => {
    const req = makeRequest(makeFullUrl());
  
    await assertRejects(
      () => handleDenyRefund(req, {
        supabase: makeSupabaseMock({ updateError: { message: "constraint violation" } }),
        sendEmail: () => Promise.resolve(),
      }),
      Error,
      "Refund update error: constraint violation"
    );
  });
  
  Deno.test("handleDenyRefund — throws when user is not found", async () => {
    const req = makeRequest(makeFullUrl());
  
    await assertRejects(
      () => handleDenyRefund(req, {
        supabase: makeSupabaseMock({ user: null }),
        sendEmail: () => Promise.resolve(),
      }),
      Error,
      "User not found"
    );
  });
  
  Deno.test("handleDenyRefund — throws when sendEmail fails", async () => {
    const req = makeRequest(makeFullUrl());
  
    await assertRejects(
      () => handleDenyRefund(req, {
        supabase: makeSupabaseMock(),
        sendEmail: () => Promise.reject(new Error("Email send failed: 422")),
      }),
      Error,
      "Email send failed"
    );
  });