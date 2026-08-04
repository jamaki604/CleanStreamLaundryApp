import {
  assertEquals,
  assertThrows,
} from "https://deno.land/std@0.224.0/testing/asserts.ts";
import {
  DRYER_DEFAULT_CENTS,
  functionRoute,
  HttpError,
  validateVendAmount,
} from "../_shared/cortina.ts";

const washerQuote = {
  machineId: 1,
  machineName: "Washer 1",
  machineType: "washer" as const,
  locationId: 1,
  washerSizeRateId: 10,
  washerSizeLabel: "18 kg",
  amountCents: 450,
  dryer: null,
};

const dryerQuote = {
  machineId: 2,
  machineName: "Dryer 1",
  machineType: "dryer" as const,
  locationId: 1,
  washerSizeRateId: null,
  washerSizeLabel: null,
  amountCents: DRYER_DEFAULT_CENTS,
  dryer: {
    incrementCents: 25,
    minutesPerIncrement: 5,
    minimumCents: 25,
    maximumCents: 450,
    defaultCents: 150,
  },
};

Deno.test("washer accepts only the current server price", () => {
  assertEquals(validateVendAmount(washerQuote, 450), {
    amountCents: 450,
    dryerMinutes: null,
  });
  const error = assertThrows(() => validateVendAmount(washerQuote, 475));
  assertEquals((error as HttpError).code, "price_changed");
});

Deno.test("dryer amount converts to five-minute increments", () => {
  assertEquals(validateVendAmount(dryerQuote, 150), {
    amountCents: 150,
    dryerMinutes: 30,
  });
  assertEquals(validateVendAmount(dryerQuote, 25).dryerMinutes, 5);
  assertEquals(validateVendAmount(dryerQuote, 450).dryerMinutes, 90);
});

Deno.test("dryer rejects amounts outside quarter increments", () => {
  for (const amount of [0, 30, 475]) {
    const error = assertThrows(() => validateVendAmount(dryerQuote, amount));
    assertEquals((error as HttpError).code, "invalid_dryer_amount");
  }
});

Deno.test("functionRoute resolves routed Edge Function paths", () => {
  assertEquals(
    functionRoute("https://example.supabase.co/functions/v1/cortina-vend/quote"),
    "quote",
  );
  assertEquals(
    functionRoute("https://example.supabase.co/functions/v1/cortina-vend/status"),
    "status",
  );
});
