import {
    assertEquals,
    assertRejects,
  } from "https://deno.land/std/testing/asserts.ts";
  
  import { processRefund } from "./logic.ts";
  
  function createMockDeps(overrides: Partial<any> = {}) {
    return {
      updateRefund: async (_: string) => {},
      getUserEmail: async (_: string) => "test@example.com",
      incrementLoyalty: async (_: string, __: number) => {},
      sendEmail: async (_: string, __: string, ___: string) => {},
      ...overrides,
    };
  }
  
  Deno.test("processRefund succeeds with valid input", async () => {
    const deps = createMockDeps();
  
    const result = await processRefund(
      {
        userId: "user1",
        transactionId: "tx1",
        amount: "25",
      },
      deps
    );
  
    assertEquals(result.success, true);
    assertEquals(result.transactionId, "tx1");
    assertEquals(result.amount, "25");
  });
  
  Deno.test("throws if params are missing", async () => {
    const deps = createMockDeps();
  
    await assertRejects(
      () =>
        processRefund(
          {
            userId: "",
            transactionId: "tx1",
            amount: "25",
          },
          deps
        ),
      Error,
      "Missing params"
    );
  });
  
  Deno.test("propagates updateRefund error", async () => {
    const deps = createMockDeps({
      updateRefund: async () => {
        throw new Error("DB failure");
      },
    });
  
    await assertRejects(
      () =>
        processRefund(
          {
            userId: "user1",
            transactionId: "tx1",
            amount: "25",
          },
          deps
        ),
      Error,
      "DB failure"
    );
  });
  
  Deno.test("throws if user email not found", async () => {
    const deps = createMockDeps({
      getUserEmail: async () => "",
    });
  
    await assertRejects(
      () =>
        processRefund(
          {
            userId: "user1",
            transactionId: "tx1",
            amount: "25",
          },
          deps
        ),
      Error,
      "User email not found"
    );
  });
  
  Deno.test("propagates incrementLoyalty error", async () => {
    const deps = createMockDeps({
      incrementLoyalty: async () => {
        throw new Error("RPC failed");
      },
    });
  
    await assertRejects(
      () =>
        processRefund(
          {
            userId: "user1",
            transactionId: "tx1",
            amount: "25",
          },
          deps
        ),
      Error,
      "RPC failed"
    );
  });
  
  Deno.test("propagates sendEmail error", async () => {
    const deps = createMockDeps({
      sendEmail: async () => {
        throw new Error("Email failed");
      },
    });
  
    await assertRejects(
      () =>
        processRefund(
          {
            userId: "user1",
            transactionId: "tx1",
            amount: "25",
          },
          deps
        ),
      Error,
      "Email failed"
    );
  });