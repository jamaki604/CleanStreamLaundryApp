drop policy if exists washer_rates_location_admin_select
on public.washer_size_rates;
drop policy if exists washer_rates_location_owner_write
on public.washer_size_rates;

create policy washer_rates_location_admin_select
on public.washer_size_rates for select to authenticated
using (
  exists (
    select 1
    from public."Location_to_Admin" lta
    join public.profiles p on p.id = lta.user_id
    where lta.location_id = washer_size_rates.location_id
      and lta.user_id = (select auth.uid())
      and p.roles in ('Admin'::public."Roles", 'Owner'::public."Roles")
  )
);

create policy washer_rates_location_owner_insert
on public.washer_size_rates for insert to authenticated
with check (
  exists (
    select 1
    from public."Location_to_Admin" lta
    join public.profiles p on p.id = lta.user_id
    where lta.location_id = washer_size_rates.location_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
);

create policy washer_rates_location_owner_update
on public.washer_size_rates for update to authenticated
using (
  exists (
    select 1
    from public."Location_to_Admin" lta
    join public.profiles p on p.id = lta.user_id
    where lta.location_id = washer_size_rates.location_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
)
with check (
  exists (
    select 1
    from public."Location_to_Admin" lta
    join public.profiles p on p.id = lta.user_id
    where lta.location_id = washer_size_rates.location_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
);

create policy washer_rates_location_owner_delete
on public.washer_size_rates for delete to authenticated
using (
  exists (
    select 1
    from public."Location_to_Admin" lta
    join public.profiles p on p.id = lta.user_id
    where lta.location_id = washer_size_rates.location_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
);

drop policy if exists cortina_config_location_admin_select
on public.cortina_machine_config;
drop policy if exists cortina_config_location_owner_write
on public.cortina_machine_config;

create policy cortina_config_location_admin_select
on public.cortina_machine_config for select to authenticated
using (
  exists (
    select 1
    from public."Machines" m
    join public."Location_to_Admin" lta on lta.location_id = m."Location_ID"
    join public.profiles p on p.id = lta.user_id
    where m.id = cortina_machine_config.machine_id
      and lta.user_id = (select auth.uid())
      and p.roles in ('Admin'::public."Roles", 'Owner'::public."Roles")
  )
);

create policy cortina_config_location_owner_insert
on public.cortina_machine_config for insert to authenticated
with check (
  exists (
    select 1
    from public."Machines" m
    join public."Location_to_Admin" lta on lta.location_id = m."Location_ID"
    join public.profiles p on p.id = lta.user_id
    where m.id = cortina_machine_config.machine_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
);

create policy cortina_config_location_owner_update
on public.cortina_machine_config for update to authenticated
using (
  exists (
    select 1
    from public."Machines" m
    join public."Location_to_Admin" lta on lta.location_id = m."Location_ID"
    join public.profiles p on p.id = lta.user_id
    where m.id = cortina_machine_config.machine_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
)
with check (
  exists (
    select 1
    from public."Machines" m
    join public."Location_to_Admin" lta on lta.location_id = m."Location_ID"
    join public.profiles p on p.id = lta.user_id
    where m.id = cortina_machine_config.machine_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
);

create policy cortina_config_location_owner_delete
on public.cortina_machine_config for delete to authenticated
using (
  exists (
    select 1
    from public."Machines" m
    join public."Location_to_Admin" lta on lta.location_id = m."Location_ID"
    join public.profiles p on p.id = lta.user_id
    where m.id = cortina_machine_config.machine_id
      and lta.user_id = (select auth.uid())
      and p.roles = 'Owner'::public."Roles"
  )
);
