import {
    assertEquals,
    assertRejects,
  } from "https://deno.land/std@0.168.0/testing/asserts.ts";
  import {
    extractParams,
    denyRefundInDb,
    getUserEmail,
    handleDenyRefund,
    sendDenialEmail
  } from "./logic.ts";
  
  function makeRequestWithBody(body: Record<string, string>) {
    return new Request("http://localhost/deny-refund", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  }

  function makeFullRequest(overrides: Partial<Record<"user_id" | "transaction_id" | "amount" | "note", string>> = {}) {
    return makeRequestWithBody({
      user_id: "user-123",
      transaction_id: "txn-abc",
      amount: "25.00",
      note: "Policy violation",
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

  function mockFetch(ok: boolean, responseText = "") {
    globalThis.fetch = () =>
      Promise.resolve({
        ok,
        text: () => Promise.resolve(responseText),
      } as Response);
  }

  function restoreFetch() {
    globalThis.fetch = fetch;
  }

  Deno.test("extractParams — returns all four params when present", async () => {
    const req = makeFullRequest();
    const params = await extractParams(req);

    assertEquals(params.userId, "user-123");
    assertEquals(params.transactionId, "txn-abc");
    assertEquals(params.amount, "25.00");
    assertEquals(params.note, "Policy violation");
  });


  Deno.test("extractParams — allows missing note parameter", async () => {
    const req = makeRequestWithBody({ user_id: "user-123", transaction_id: "txn-abc", amount: "25.00" });
    const params = await extractParams(req);

    assertEquals(params.userId, "user-123");
    assertEquals(params.transactionId, "txn-abc");
    assertEquals(params.amount, "25.00");
    assertEquals(params.note, undefined);
  });

  Deno.test("extractParams — throws when body is not valid JSON", async () => {
    const req = new Request("http://localhost/deny-refund", {
      method: "POST",
      body: "not valid json",
    });

    await assertRejects(
      () => extractParams(req),
      Error,
      "Invalid JSON body"
    );
  });

  Deno.test("denyRefundInDb — resolves without error on success", async () => {
    const supabase = makeSupabaseMock();
    await denyRefundInDb(supabase, "txn-abc", "Policy violation");
  });

  Deno.test("denyRefundInDb — throws with prefixed message on Supabase error", async () => {
    const supabase = makeSupabaseMock({ updateError: { message: "row not found" } });

    await assertRejects(
      () => denyRefundInDb(supabase, "txn-abc", "Policy violation"),
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

    await denyRefundInDb(supabase, "txn-xyz", "Policy violation");
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
    const supabase = makeSupabaseMock({ user: { id: "user-123" } });

    await assertRejects(
      () => getUserEmail(supabase, "user-123"),
      Error,
      "User email not found"
    );
  });

  Deno.test("handleDenyRefund — returns 200 with confirmation HTML on success", async () => {
    const req = makeFullRequest();
    const sendEmail = (_to: string, _txn: string, _amt: string, _note: string) => Promise.resolve();

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
    const req = makeFullRequest();
    let capturedArgs: [string, string, string, string] | undefined;

    await handleDenyRefund(req, {
      supabase: makeSupabaseMock(),
      sendEmail: (to, txn, amt, note) => {
        capturedArgs = [to, txn, amt, note];
        return Promise.resolve();
      },
    });

    assertEquals(capturedArgs, ["user@example.com", "txn-abc", "25.00", "Policy violation"]);
  });

  Deno.test("handleDenyRefund — throws when DB update fails", async () => {
    const req = makeFullRequest();

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
    const req = makeFullRequest();

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
    const req = makeFullRequest();

    await assertRejects(
      () => handleDenyRefund(req, {
        supabase: makeSupabaseMock(),
        sendEmail: () => Promise.reject(new Error("Email send failed: 422")),
      }),
      Error,
      "Email send failed"
    );
  });

  Deno.test("sendDenialEmail — resolves without error on success", async () => {
    mockFetch(true);
    try {
      await sendDenialEmail("test-api-key", "user@example.com", "txn-abc", "25.00", "Policy violation");
    } finally {
      restoreFetch();
    }
  });

  Deno.test("sendDenialEmail — throws with error text when response is not ok", async () => {
    mockFetch(false, "Invalid API key");
    try {
      await assertRejects(
        () => sendDenialEmail("bad-key", "user@example.com", "txn-abc", "25.00", "Policy violation"),
        Error,
        "Email send failed: Invalid API key"
      );
    } finally {
      restoreFetch();
    }
  });

  Deno.test("sendDenialEmail — sends POST to the correct Resend endpoint", async () => {
    let capturedUrl: string | undefined;
    let capturedInit: RequestInit | undefined;

    globalThis.fetch = (url: string | URL | Request, init?: RequestInit) => {
      capturedUrl = url.toString();
      capturedInit = init;
      return Promise.resolve({ ok: true, text: () => Promise.resolve("") } as Response);
    };

    try {
      await sendDenialEmail("test-key", "user@example.com", "txn-abc", "25.00", "Policy violation");
    } finally {
      restoreFetch();
    }

    assertEquals(capturedUrl, "https://api.resend.com/emails");
    assertEquals(capturedInit?.method, "POST");
  });

  Deno.test("sendDenialEmail — sends correct Authorization header", async () => {
    let capturedHeaders: Record<string, string> | undefined;

    globalThis.fetch = (_url: string | URL | Request, init?: RequestInit) => {
      capturedHeaders = init?.headers as Record<string, string>;
      return Promise.resolve({ ok: true, text: () => Promise.resolve("") } as Response);
    };

    try {
      await sendDenialEmail("my-resend-key", "user@example.com", "txn-abc", "25.00", "Policy violation");
    } finally {
      restoreFetch();
    }

    assertEquals(capturedHeaders?.["Authorization"], "Bearer my-resend-key");
    assertEquals(capturedHeaders?.["Content-Type"], "application/json");
  });

  Deno.test("sendDenialEmail — sends correct recipient, transactionId, amount, and note in body", async () => {
    let capturedBody: any;

    globalThis.fetch = (_url: string | URL | Request, init?: RequestInit) => {
      capturedBody = JSON.parse(init?.body as string);
      return Promise.resolve({ ok: true, text: () => Promise.resolve("") } as Response);
    };

    try {
      await sendDenialEmail("test-key", "customer@example.com", "txn-xyz", "49.99", "Custom note here");
    } finally {
      restoreFetch();
    }

    assertEquals(capturedBody.to, "customer@example.com");
    assertEquals(capturedBody.html.includes("txn-xyz"), true);
    assertEquals(capturedBody.html.includes("49.99"), true);
    assertEquals(capturedBody.html.includes("Custom note here"), true);
    assertEquals(capturedBody.subject, "Refund Request Denied");
  });