export interface Dependencies {
    random: () => number;
    delay: (ms: number) => Promise<void>;
    now: () => Date;
  }
  
  export async function handleWakeDevice(
    body: any,
    deps: Dependencies
  ) {
    const { random, delay, now } = deps;
  
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
  
    const timestamp = now().toISOString();
  
    if (success) {
      return {
        status: 200,
        body: {
          success: true,
          deviceId,
          message: "Device wake signal sent successfully",
          timestamp,
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
        timestamp,
        responseTime: `${responseDelay}ms`,
      },
    };
  }