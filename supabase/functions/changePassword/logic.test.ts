import { assertEquals, assertRejects } from "https://deno.land/std/testing/asserts.ts";
import { resetPassword } from "./logic.ts";

function createMockDeps(overrides: Partial<any> = {}) {
  return {
    exchangeCode: async (code: string) => ({ userId: "user1" }),
    updatePassword: async (userId: string, password: string) => {},
    ...overrides,
  };
}

Deno.test("resetPassword succeeds with valid input", async () => {
  const deps = createMockDeps();

  const result = await resetPassword(
    { code: "abc123", password: "newpass" },
    deps
  );

  assertEquals(result.success, true);
  assertEquals(result.userId, "user1");
});

Deno.test("throws if code or password is missing", async () => {
  const deps = createMockDeps();

  await assertRejects(
    () => resetPassword({ code: "", password: "newpass" }, deps),
    Error,
    "Missing code or password"
  );
});

Deno.test("throws if exchangeCode returns no userId", async () => {
  const deps = createMockDeps({
    exchangeCode: async () => ({ userId: "" }),
  });

  await assertRejects(
    () => resetPassword({ code: "abc123", password: "newpass" }, deps),
    Error,
    "Invalid or expired code"
  );
});

Deno.test("propagates updatePassword error", async () => {
  const deps = createMockDeps({
    updatePassword: async () => {
      throw new Error("Update failed");
    },
  });

  await assertRejects(
    () => resetPassword({ code: "abc123", password: "newpass" }, deps),
    Error,
    "Update failed"
  );
});