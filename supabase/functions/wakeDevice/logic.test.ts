import {
    handleWakeDevice,
  } from "./logic.ts";
  
  import {
    assertEquals,
  } from "https://deno.land/std@0.224.0/testing/asserts.ts";

  
  function createDeps(options?: {
    randomValues?: number[];
  }) {
    let delayCalledWith = 0;
  
    const randomValues = options?.randomValues ?? [0.1, 0.5];
    let randomIndex = 0;
  
    return {
      deps: {
        random: () => randomValues[randomIndex++],
        delay: async (ms: number) => {
          delayCalledWith = ms;
        },
        now: () => new Date("2024-01-01T00:00:00.000Z"),
      },
      getDelay: () => delayCalledWith,
    };
  }
  

  Deno.test("returns 400 if deviceId missing", async () => {
    const { deps } = createDeps();
  
    const result = await handleWakeDevice({}, deps);
  
    assertEquals(result.status, 400);
    assertEquals(result.body.error, "deviceId is required");
  });
  
  Deno.test("returns success when random < 0.95", async () => {
    const { deps, getDelay } = createDeps({
      randomValues: [0.1, 0.5],
    });
  
    const result = await handleWakeDevice(
      { deviceId: "abc123" },
      deps
    );
  
    assertEquals(result.status, 200);
    assertEquals(result.body.success, true);
    assertEquals(result.body.deviceId, "abc123");
    assertEquals(result.body.timestamp, "2024-01-01T00:00:00.000Z");
  
    assertEquals(getDelay(), 125);
    assertEquals(result.body.responseTime, "125ms");
  });
  
  Deno.test("returns 503 when random >= 0.95", async () => {
    const { deps } = createDeps({
      randomValues: [0.99, 0.3],
    });
  
    const result = await handleWakeDevice(
      { deviceId: "abc123" },
      deps
    );
  
    assertEquals(result.status, 503);
    assertEquals(result.body.success, false);
    assertEquals(result.body.error, "Device unreachable or timeout");
  });
  
  Deno.test("delay is awaited with correct ms", async () => {
    const { deps, getDelay } = createDeps({
      randomValues: [0.1, 0.0], 
    });
  
    await handleWakeDevice(
      { deviceId: "abc123" },
      deps
    );
  
    assertEquals(getDelay(), 50);
  });