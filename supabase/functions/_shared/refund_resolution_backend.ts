import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.97.0";
import {
  RefundHttpError,
  refundEmailHtml,
  type RefundResolution,
  type RefundResolutionDependencies,
} from "./refund_resolution.ts";

export function createRefundResolutionDependencies(
  admin: SupabaseClient,
  resendApiKey: string | undefined,
): RefundResolutionDependencies {
  return {
    authenticate: async (req) => {
      const authorization = req.headers.get("authorization");
      if (!authorization?.toLowerCase().startsWith("bearer ")) {
        throw new RefundHttpError(401, "Authentication required");
      }

      const { data, error } = await admin.auth.getUser(
        authorization.slice(7).trim(),
      );
      if (error || !data.user) {
        throw new RefundHttpError(401, "Invalid or expired session");
      }
      return data.user.id;
    },

    resolve: async ({ refundId, decision, note, actorUserId }) => {
      const { data, error } = await admin.rpc("resolve_refund_request", {
        target_refund_id: refundId,
        target_decision: decision,
        resolution_note: note,
        actor_user_id: actorUserId,
      });
      if (error) {
        if (error.message.includes("Unauthorized")) {
          throw new RefundHttpError(403, "Owner or Admin access required");
        }
        if (error.message.includes("not found")) {
          throw new RefundHttpError(404, "Refund request not found");
        }
        if (error.message.includes("already")) {
          throw new RefundHttpError(409, error.message);
        }
        throw new Error(error.message);
      }
      if (!data || typeof data !== "object") {
        throw new Error("Refund resolution returned an invalid response");
      }
      return data as RefundResolution;
    },

    notify: async (resolution, note) => {
      if (!resendApiKey) {
        throw new Error("Loyalty credit resolved, but email is not configured");
      }

      const { data, error } = await admin.auth.admin.getUserById(
        resolution.customerId,
      );
      const email = data?.user?.email;
      if (error || !email) {
        throw new Error(
          "Loyalty credit resolved, but customer email was not found",
        );
      }

      const approved = resolution.status === "approved";
      const response = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${resendApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: "refund@updates.cleanstreamlaundry.com",
          to: email,
          subject: approved
            ? "Your Loyalty Balance Credit Was Approved"
            : "Loyalty Balance Credit Request Denied",
          html: refundEmailHtml(resolution.status, resolution, note),
        }),
      });
      if (!response.ok) {
        throw new Error(
          `Loyalty credit resolved, but email failed with HTTP ${response.status}`,
        );
      }
    },

    markNotificationSent: async (refundId) => {
      const { error } = await admin.from("Refunds").update({
        notification_sent_at: new Date().toISOString(),
      }).eq("refund_id", refundId);
      if (error) throw new Error("Customer was emailed, but notification tracking failed");
    },
  };
}
