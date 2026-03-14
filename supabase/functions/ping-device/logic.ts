export type MachineStatus =
  | "idle"
  | "in-use"
  | "offline"
  | "error";

export interface Dependencies {
  getMachineStatus: (deviceId: string) => Promise<MachineStatus>;
  random: () => number;
  delay: (ms: number) => Promise<void>;
}

export async function handleMachineRequest(
  body: any,
  deps: Dependencies
) {
  const { getMachineStatus, random, delay } = deps;

  const deviceId = body?.deviceId;

  if (!deviceId) {
    return {
      status: 400,
      body: {
        error: "deviceId is required",
        receivedBody: body,
      },
    };
  }

  const success = random() < 0.95;
  const responseDelay = Math.floor(random() * 150) + 50;

  await delay(responseDelay);

  const machineStatus = await getMachineStatus(deviceId);

  if (success) {
    return {
      status: 200,
      body: {
        success: true,
        deviceId,
        message: machineStatus,
        timestamp: new Date().toISOString(),
        responseTime: `${responseDelay}ms`,
      },
    };
  }

  return {
    status: 503,
    body: {
      success: false,
      deviceId,
      error: "Device unreachable or timeout",
      timestamp: new Date().toISOString(),
      responseTime: `${responseDelay}ms`,
    },
  };
}