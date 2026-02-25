import {
    assertEquals,
    assertRejects,
  } from "https://deno.land/std@0.168.0/testing/asserts.ts";
  import {
    getAuthenticatedUser,
    createCheckoutSession,
  } from "./logic.ts";
  
  function makeSupabaseMock(user: object | null, error: object | null = null) {
    return {
      auth: {
        getUser: () => Promise.resolve({ data: { user }, error }),
      },
    } as any;
  }
  
  function makeStripeMock(overrides?: Partial<{ url: string; id: string }>) {
    return {
      checkout: {
        sessions: {
          create: (_params: unknown) =>
            Promise.resolve({
              url: overrides?.url ?? "https://checkout.stripe.com/pay/test_session",
              id: overrides?.id ?? "cs_test_abc123",
            }),
        },
      },
    } as any;
  }
  
  Deno.test("getAuthenticatedUser — returns user when authenticated", async () => {
    const mockUser = { id: "user-123", email: "test@example.com" };
    const supabase = makeSupabaseMock(mockUser);
  
    const user = await getAuthenticatedUser(supabase);
    assertEquals(user.id, "user-123");
  });
  
  Deno.test("getAuthenticatedUser — throws when user is null", async () => {
    const supabase = makeSupabaseMock(null);
  
    await assertRejects(
      () => getAuthenticatedUser(supabase),
      Error,
      "Unauthorized"
    );
  });
  
  Deno.test("getAuthenticatedUser — throws when Supabase returns an error", async () => {
    const supabase = makeSupabaseMock(null, { message: "JWT expired" });
  
    await assertRejects(
      () => getAuthenticatedUser(supabase),
      Error,
      "Unauthorized"
    );
  });
  
  Deno.test("createCheckoutSession — returns url and session_id", async () => {
    const stripe = makeStripeMock();
  
    const result = await createCheckoutSession(stripe, 2500, "user-123");
  
    assertEquals(result.session_id, "cs_test_abc123");
    assertEquals(result.url, "https://checkout.stripe.com/pay/test_session");
  });
  
  Deno.test("createCheckoutSession — passes correct amount to Stripe", async () => {
    let capturedParams: any;
    const stripe = {
      checkout: {
        sessions: {
          create: (params: unknown) => {
            capturedParams = params;
            return Promise.resolve({ url: "https://stripe.com", id: "cs_1" });
          },
        },
      },
    } as any;
  
    await createCheckoutSession(stripe, 4999, "user-456");
  
    assertEquals(capturedParams.line_items[0].price_data.unit_amount, 4999);
    assertEquals(capturedParams.metadata.user_id, "user-456");
  });
  
  Deno.test("createCheckoutSession — throws on invalid amount (zero)", async () => {
    const stripe = makeStripeMock();
  
    await assertRejects(
      () => createCheckoutSession(stripe, 0, "user-123"),
      Error,
      "Invalid amount"
    );
  });
  
  Deno.test("createCheckoutSession — throws on negative amount", async () => {
    const stripe = makeStripeMock();
  
    await assertRejects(
      () => createCheckoutSession(stripe, -100, "user-123"),
      Error,
      "Invalid amount"
    );
  });
  
  Deno.test("createCheckoutSession — uses custom baseUrl for redirect URLs", async () => {
    let capturedParams: any;
    const stripe = {
      checkout: {
        sessions: {
          create: (params: unknown) => {
            capturedParams = params;
            return Promise.resolve({ url: "https://stripe.com", id: "cs_1" });
          },
        },
      },
    } as any;
  
    await createCheckoutSession(stripe, 1000, "user-123", "https://myapp.com");
  
    assertEquals(capturedParams.success_url, "https://myapp.com/homePage");
    assertEquals(capturedParams.cancel_url, "https://myapp.com/homePage");
  });
  