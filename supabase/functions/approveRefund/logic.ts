export interface RefundDependencies {
    updateRefund: (transactionId: string, note: string) => Promise<void>;
    getUserEmail: (userId: string) => Promise<string>;
    creditWallet: (userId: string, amount: number, note: string) => Promise<void>;
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
  
    await deps.creditWallet(userId, Number(amount), note);
  
    await deps.sendEmail(email, transactionId, amount, note);
  
    return {
      success: true,
      transactionId,
      amount,
    };
  }
