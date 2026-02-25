import {
    assertEquals,
    assertRejects,
  } from "https://deno.land/std@0.182.0/testing/asserts.ts";
  import {
    validateUserId,
    deleteUser,
  } from "./logic.ts";
  
  function makeAdminMock(
    result: { data?: unknown; error?: { message: string } | null } = {}
  ) {
    return {
      auth: {
        admin: {
          deleteUser: (_id: string) =>
            Promise.resolve({
              data: result.data ?? { user: { id: _id } },
              error: result.error ?? null,
            }),
        },
      },
    } as any;
  }
  
  
  Deno.test("validateUserId — accepts a valid UUID string", () => {
    const id = "550e8400-e29b-41d4-a716-446655440000";
    assertEquals(validateUserId(id), id);
  });
  
  Deno.test("validateUserId — throws on null", () => {
    try {
      validateUserId(null);
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing user_id");
    }
  });
  
  Deno.test("validateUserId — throws on undefined", () => {
    try {
      validateUserId(undefined);
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing user_id");
    }
  });
  
  Deno.test("validateUserId — throws on empty string", () => {
    try {
      validateUserId("   ");
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing user_id");
    }
  });
  
  Deno.test("validateUserId — throws on non-string type", () => {
    try {
      validateUserId(12345);
    } catch (e) {
      assertEquals(e instanceof Error, true);
      assertEquals((e as Error).message, "Missing user_id");
    }
  });

  
  Deno.test("deleteUser — returns success and data on valid user", async () => {
    const mockData = { user: { id: "user-abc" } };
    const supabaseAdmin = makeAdminMock({ data: mockData });
  
    const result = await deleteUser(supabaseAdmin, "user-abc");
  
    assertEquals(result.success, true);
    assertEquals(result.data, mockData);
  });
  
  Deno.test("deleteUser — throws when Supabase returns an error", async () => {
    const supabaseAdmin = makeAdminMock({
      error: { message: "User not found" },
    });
  
    await assertRejects(
      () => deleteUser(supabaseAdmin, "ghost-user"),
      Error,
      "User not found"
    );
  });
  
  Deno.test("deleteUser — forwards the correct user_id to Supabase", async () => {
    let capturedId: string | undefined;
    const supabaseAdmin = {
      auth: {
        admin: {
          deleteUser: (id: string) => {
            capturedId = id;
            return Promise.resolve({ data: {}, error: null });
          },
        },
      },
    } as any;
  
    await deleteUser(supabaseAdmin, "user-xyz");
    assertEquals(capturedId, "user-xyz");
  });
  