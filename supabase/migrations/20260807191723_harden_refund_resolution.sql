begin;

alter table public."Refunds"
  add column if not exists admin_note text,
  add column if not exists resolved_by uuid references auth.users(id) on delete set null,
  add column if not exists resolved_at timestamptz,
  add column if not exists notification_sent_at timestamptz;

alter table public.wallet_ledger_entries
  add column if not exists refund_request_id bigint
    references public."Refunds"(refund_id) on delete set null;

create unique index if not exists wallet_ledger_refund_request_unique
  on public.wallet_ledger_entries(refund_request_id)
  where refund_request_id is not null;

create or replace function public.resolve_refund_request(
  target_refund_id bigint,
  target_decision text,
  resolution_note text,
  actor_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  target_refund public."Refunds"%rowtype;
  wallet_id uuid;
  refund_amount_cents integer;
  normalized_note text := nullif(btrim(coalesce(resolution_note, '')), '');
begin
  if actor_user_id is null or not exists (
    select 1
    from public.profiles
    where id = actor_user_id
      and roles in ('Admin'::public."Roles", 'Owner'::public."Roles")
  ) then
    raise exception using errcode = '42501', message = 'Unauthorized';
  end if;

  if target_decision not in ('approved', 'denied') then
    raise exception using errcode = '22023', message = 'Invalid refund decision';
  end if;

  select *
  into target_refund
  from public."Refunds"
  where refund_id = target_refund_id
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'Refund request not found';
  end if;

  if target_refund.status::text <> 'pending' then
    if target_refund.status::text <> target_decision then
      raise exception using
        errcode = 'P0001',
        message = format('Refund request is already %s', target_refund.status::text);
    end if;

    return jsonb_build_object(
      'success', true,
      'alreadyResolved', true,
      'refundId', target_refund.refund_id,
      'transactionId', target_refund.transaction_id,
      'customerId', target_refund.user_id,
      'amount', target_refund.amount,
      'status', target_refund.status::text,
      'notificationSent', target_refund.notification_sent_at is not null
    );
  end if;

  if target_decision = 'approved' then
    refund_amount_cents := round((target_refund.amount * 100)::numeric)::integer;
    if refund_amount_cents is null or refund_amount_cents <= 0 then
      raise exception using errcode = '22023', message = 'Refund amount must be positive';
    end if;

    wallet_id := public.get_or_create_wallet_account(target_refund.user_id);

    insert into public.wallet_ledger_entries(
      wallet_account_id,
      entry_type,
      amount_cents,
      paid_amount_cents,
      promo_amount_cents,
      note,
      created_by,
      refund_request_id
    )
    values (
      wallet_id,
      'admin_adjustment',
      refund_amount_cents,
      0,
      refund_amount_cents,
      concat(
        'Approved loyalty balance credit',
        case when normalized_note is null then '' else ': ' || normalized_note end
      ),
      actor_user_id,
      target_refund.refund_id
    );

    perform public.sync_profile_wallet_balance(wallet_id);
  end if;

  update public."Refunds"
  set status = target_decision::public.refund_status,
      admin_note = normalized_note,
      resolved_by = actor_user_id,
      resolved_at = now()
  where refund_id = target_refund.refund_id;

  return jsonb_build_object(
    'success', true,
    'alreadyResolved', false,
    'refundId', target_refund.refund_id,
    'transactionId', target_refund.transaction_id,
    'customerId', target_refund.user_id,
    'amount', target_refund.amount,
    'status', target_decision,
    'notificationSent', false
  );
end;
$$;

revoke all on function public.resolve_refund_request(bigint, text, text, uuid)
  from public, anon, authenticated;
grant execute on function public.resolve_refund_request(bigint, text, text, uuid)
  to service_role;

commit;
