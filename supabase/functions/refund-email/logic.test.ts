import {
    handleRefundRequest,
  } from "./logic.ts";
  
  import {
    assertEquals,
    assert,
  } from "https://deno.land/std@0.224.0/testing/asserts.ts";
  
  function createDeps() {
    let capturedSubject = "";
    let capturedHtml = "";
  
    return {
      deps: {
        sendEmail: async ({ subject, html }: any) => {
          capturedSubject = subject;
          capturedHtml = html;
          return { id: "email_123" };
        },
      },
      getCaptured: () => ({
        subject: capturedSubject,
        html: capturedHtml,
      }),
    };
  }
  
  const validBody = {
    username: "John",
    user_id: "u123",
    transaction_id: "t456",
    amount: 25,
    description: "Machine ate my sock",
    userAttempts: 2,
  };
  
  Deno.test("returns 400 if required fields missing", async () => {
    const { deps } = createDeps();
  
    const result = await handleRefundRequest({}, deps);
  
    assertEquals(result.status, 400);
    assertEquals(result.body.error, "Missing required fields");
  });
  
  Deno.test("returns 200 on valid request", async () => {
    const { deps } = createDeps();
  
    const result = await handleRefundRequest(validBody, deps);
  
    assertEquals(result.status, 200);
    assertEquals(result.body.success, true);
    assertEquals(result.body.resend.id, "email_123");
  });
  
  Deno.test("email subject contains username", async () => {
    const { deps, getCaptured } = createDeps();
  
    await handleRefundRequest(validBody, deps);
  
    const { subject } = getCaptured();
  
    assert(subject.includes("John"));
  });
  
  Deno.test("email contains approve and deny links", async () => {
    const { deps, getCaptured } = createDeps();
  
    await handleRefundRequest(validBody, deps);
  
    const { html } = getCaptured();
  
    assert(html.includes("approveRefund"));
    assert(html.includes("denyRefund"));
    assert(html.includes("u123"));
    assert(html.includes("t456"));
  });
  
  Deno.test("email includes refund details", async () => {
    const { deps, getCaptured } = createDeps();
  
    await handleRefundRequest(validBody, deps);
  
    const { html } = getCaptured();
  
    assert(html.includes("Machine ate my sock"));
    assert(html.includes("$25"));
  });