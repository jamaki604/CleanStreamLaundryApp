import {
  assertEquals,
  assertObjectMatch,
} from "https://deno.land/std@0.168.0/testing/asserts.ts";
import { handleMachineRequest, Dependencies, MachineStatus } from "./logic.ts";

function makeDeps(overrides: Partial<Dependencies> = {}): Dependencies {
  return {
    getMachineStatus: (_id: string) => Promise.resolve("idle" as MachineStatus),
    random: () => 0.5,
    delay: (_ms: number) => Promise.resolve(),
    ...overrides,
  };
}

Deno.test("handleMachineRequest — returns 400 when body is null", async () => {
  const result = await handleMachineRequest(null, makeDeps());
  assertEquals(result.status, 400);
  assertEquals(result.body, { error: "deviceId is required", receivedBody: null });
});

Deno.test("handleMachineRequest — returns 400 when body is undefined", async () => {
  const result = await handleMachineRequest(undefined, makeDeps());
  assertEquals(result.status, 400);
  assertEquals(result.body, { error: "deviceId is required", receivedBody: undefined });
});

Deno.test("handleMachineRequest — returns 400 when body has no deviceId", async () => {
  const result = await handleMachineRequest({ foo: "bar" }, makeDeps());
  assertEquals(result.status, 400);
  assertObjectMatch(result.body as Record<string, unknown>, { error: "deviceId is required" });
});

Deno.test("handleMachineRequest — returns 400 when deviceId is an empty string", async () => {
  const result = await handleMachineRequest({ deviceId: "" }, makeDeps());
  assertEquals(result.status, 400);
});

Deno.test("handleMachineRequest — does not call delay or getMachineStatus when deviceId is missing", async () => {
  let delayCalled = false;
  let getStatusCalled = false;

  const deps = makeDeps({
    delay: (_ms: number) => { delayCalled = true; return Promise.resolve(); },
    getMachineStatus: (_id: string) => { getStatusCalled = true; return Promise.resolve("idle"); },
  });

  await handleMachineRequest(null, deps);

  assertEquals(delayCalled, false);
  assertEquals(getStatusCalled, false);
});

Deno.test("handleMachineRequest — returns 200 with correct shape on success", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps());
  assertEquals(result.status, 200);
  assertObjectMatch(result.body as Record<string, unknown>, {
    success: true,
    deviceId: "device-1",
    message: "idle",
  });
});

Deno.test("handleMachineRequest — includes a valid ISO timestamp on success", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps());
  const { timestamp } = result.body as { timestamp: string };
  assertEquals(new Date(timestamp).toISOString(), timestamp);
});

Deno.test("handleMachineRequest — responseTime reflects computed delay", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps({ random: () => 0.5 }));
  assertEquals((result.body as { responseTime: string }).responseTime, "125ms");
});

Deno.test("handleMachineRequest — calls getMachineStatus with the correct deviceId", async () => {
  let capturedId = "";
  const deps = makeDeps({
    getMachineStatus: (id: string) => { capturedId = id; return Promise.resolve("idle"); },
  });

  await handleMachineRequest({ deviceId: "machine-xyz" }, deps);
  assertEquals(capturedId, "machine-xyz");
});

Deno.test("handleMachineRequest — message reflects getMachineStatus return value", async () => {
  const deps = makeDeps({
    getMachineStatus: (_id: string) => Promise.resolve("in-use" as MachineStatus),
  });
  const result = await handleMachineRequest({ deviceId: "device-1" }, deps);
  assertEquals((result.body as { message: MachineStatus }).message, "in-use");
});

Deno.test("handleMachineRequest — returns 503 when random is exactly 0.95", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps({ random: () => 0.95 }));
  assertEquals(result.status, 503);
});

Deno.test("handleMachineRequest — returns 503 when random is 1", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps({ random: () => 1 }));
  assertEquals(result.status, 503);
});

Deno.test("handleMachineRequest — returns correct error body on failure", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps({ random: () => 0.99 }));
  assertObjectMatch(result.body as Record<string, unknown>, {
    success: false,
    deviceId: "device-1",
    error: "Device unreachable or timeout",
  });
});

Deno.test("handleMachineRequest — failure body includes timestamp and responseTime", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps({ random: () => 0.99 }));
  const body = result.body as Record<string, unknown>;
  assertEquals(typeof body.timestamp, "string");
  assertEquals(typeof body.responseTime, "string");
});

Deno.test("handleMachineRequest — delay fires before getMachineStatus", async () => {
  const callOrder: string[] = [];
  const deps = makeDeps({
    delay: (_ms: number) => { callOrder.push("delay"); return Promise.resolve(); },
    getMachineStatus: (_id: string) => { callOrder.push("getMachineStatus"); return Promise.resolve("idle"); },
  });

  await handleMachineRequest({ deviceId: "device-1" }, deps);
  assertEquals(callOrder, ["delay", "getMachineStatus"]);
});

Deno.test("handleMachineRequest — delay is floor(random() * 150) + 50 (min: random = 0)", async () => {
  let capturedMs = -1;
  const deps = makeDeps({
    random: () => 0,
    delay: (ms: number) => { capturedMs = ms; return Promise.resolve(); },
  });

  await handleMachineRequest({ deviceId: "device-1" }, deps);
  assertEquals(capturedMs, 50);
});

Deno.test("handleMachineRequest — delay is within [50, 199] when random is near 1", async () => {
  let capturedMs = -1;
  const deps = makeDeps({
    random: () => 0.9999,
    delay: (ms: number) => { capturedMs = ms; return Promise.resolve(); },
  });

  await handleMachineRequest({ deviceId: "device-1" }, deps);
  assertEquals(capturedMs >= 50, true);
  assertEquals(capturedMs <= 199, true);
});


Deno.test("handleMachineRequest — returns 200 when random is just below 0.95", async () => {
  const result = await handleMachineRequest({ deviceId: "device-1" }, makeDeps({ random: () => 0.9499 }));
  assertEquals(result.status, 200);
});

const statuses: MachineStatus[] = ["idle", "in-use", "offline", "error"];

for (const status of statuses) {
  Deno.test(`handleMachineRequest — status "${status}" propagates to success body`, async () => {
    const deps = makeDeps({
      getMachineStatus: (_id: string) => Promise.resolve(status),
    });
    const result = await handleMachineRequest({ deviceId: "dev" }, deps);
    assertEquals((result.body as { message: MachineStatus }).message, status);
  });
}