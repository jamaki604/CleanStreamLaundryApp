export interface RefundDependencies {
    updateRefund: (transactionId: string, note: string) => Promise<void>;
    getUserEmail: (userId: string) => Promise<string>;
    incrementLoyalty: (userId: string, amount: number) => Promise<void>;
    sendEmail: (email: string, transactionId: string, amount: string, note: string) => Promise<void>;
  }
  
  export interface RefundParams {
    userId: string;
    transactionId: string;
    amount: string;
    note: string;
  }
  
  export async function processRefund(
    params: RefundParams,
    deps: RefundDependencies
  ) {
    const { userId, transactionId, amount, note } = params;
  
    if (!userId || !transactionId || !amount) {
      throw new Error("Missing params");
    }
  
    await deps.updateRefund(transactionId, note);
  
    const email = await deps.getUserEmail(userId);
  
    if (!email) {
      throw new Error("User email not found");
    }
  
    await deps.incrementLoyalty(userId, Number(amount));
  
    await deps.sendEmail(email, transactionId, amount, note);
  
    return {
      success: true,
      transactionId,
      amount,
    };
  }