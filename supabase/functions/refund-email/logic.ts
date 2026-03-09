export interface RefundRequestBody {
    username?: string;
    user_id?: string;
    transaction_id?: string;
    amount?: number;
    description?: string;
    userAttempts?: number;
  }
  
  export interface Dependencies {
    sendEmail: (params: {
      subject: string;
      html: string;
    }) => Promise<any>;
  }
  
  export async function handleRefundRequest(
    body: RefundRequestBody,
    deps: Dependencies
  ) {
    const { sendEmail } = deps;
  
    const {
      username,
      user_id,
      transaction_id,
      amount,
      description,
      userAttempts,
    } = body;
  
    if (!username || !user_id || !transaction_id || !amount) {
      return {
        status: 400,
        body: {
          error: "Missing required fields",
          received: body,
        },
      };
    }
  
    const approveLink =
      `https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1/approveRefund` +
      `?user_id=${user_id}&transaction_id=${transaction_id}&amount=${amount}`;
  
    const denyLink =
      `https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1/denyRefund` +
      `?user_id=${user_id}&transaction_id=${transaction_id}&amount=${amount}`;
  
    const emailBody = `
        <h2>Refund Request Received</h2>
        <p><strong>Name:</strong> ${username}</p>
        <p><strong>User ID:</strong> ${user_id}</p>
        <p><strong>Transaction ID:</strong> ${transaction_id}</p>
        <p><strong>Amount:</strong> $${amount}</p>
        <p><strong>Reason:</strong> ${description}</p>
        <p><strong>Number of refund attempts:</strong> ${userAttempts}</p>
        <div>
          <a href="${approveLink}">Approve Refund</a>
          <a href="${denyLink}">Deny Refund</a>
        </div>
    `;
  
    const emailResult = await sendEmail({
      subject: `New Refund Request - ${username}`,
      html: emailBody,
    });
  
    return {
      status: 200,
      body: {
        success: true,
        resend: emailResult,
      },
    };
  }