begin;

alter table public.cortina_vend_sessions
  add column if not exists pulse_line_number integer
    check (pulse_line_number is null or pulse_line_number > 0);

comment on column public.cortina_vend_sessions.pulse_line_number is
  'Server-selected Nayax pulse line preserved with the paid vend quote.';

commit;
