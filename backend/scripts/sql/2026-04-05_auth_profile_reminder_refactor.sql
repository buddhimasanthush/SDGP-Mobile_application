-- MediFind production auth/profile/reminder refactor
-- Run in Supabase SQL editor (or psql) as a privileged role.

begin;

-- 1) Canonical credential map linked to Supabase Auth users.
create table if not exists public.user_credentials (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  email text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_credentials_username_check check (char_length(trim(username)) >= 3)
);

create index if not exists idx_user_credentials_email on public.user_credentials (email);

-- Keep updated_at in sync.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_user_credentials_touch_updated_at on public.user_credentials;
create trigger trg_user_credentials_touch_updated_at
before update on public.user_credentials
for each row
execute procedure public.touch_updated_at();

-- 2) Harden profiles relation.
-- Existing projects usually use profiles.id = auth.users.id.
-- Add/normalize FK and optional new profile_id.
alter table if exists public.profiles
  add column if not exists profile_id uuid default gen_random_uuid();

alter table if exists public.profiles
  add column if not exists updated_at timestamptz not null default now();

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'profiles_id_auth_users_fk'
  ) then
    alter table public.profiles
      add constraint profiles_id_auth_users_fk
      foreign key (id) references auth.users(id) on delete cascade;
  end if;
exception
  when undefined_table then null;
end $$;

do $$
begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='profiles' and column_name='profile_id') then
    if not exists (
      select 1
      from pg_constraint
      where conname = 'profiles_profile_id_unique'
    ) then
      alter table public.profiles
        add constraint profiles_profile_id_unique unique (profile_id);
    end if;
  end if;
exception
  when undefined_table then null;
end $$;

drop trigger if exists trg_profiles_touch_updated_at on public.profiles;
create trigger trg_profiles_touch_updated_at
before update on public.profiles
for each row
execute procedure public.touch_updated_at();

-- 3) Production reminders table with complete scheduling fields.
create table if not exists public.medication_reminders (
  reminder_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  medicine_name text not null,
  dosage text,
  interval_minutes integer not null check (interval_minutes > 0),
  duration_days integer not null check (duration_days > 0),
  start_at timestamptz not null default now(),
  end_at timestamptz,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_medication_reminders_user_id
  on public.medication_reminders(user_id);
create index if not exists idx_medication_reminders_start_at
  on public.medication_reminders(start_at);

drop trigger if exists trg_medication_reminders_touch_updated_at on public.medication_reminders;
create trigger trg_medication_reminders_touch_updated_at
before update on public.medication_reminders
for each row
execute procedure public.touch_updated_at();

create or replace function public.set_medication_reminder_end_at()
returns trigger
language plpgsql
as $$
begin
  new.end_at = new.start_at + make_interval(days => new.duration_days);
  return new;
end;
$$;

drop trigger if exists trg_set_medication_reminder_end_at on public.medication_reminders;
create trigger trg_set_medication_reminder_end_at
before insert or update of start_at, duration_days
on public.medication_reminders
for each row
execute procedure public.set_medication_reminder_end_at();

-- 4) Backfill user_credentials from current schema (safe/no password fields).
insert into public.user_credentials (user_id, username, email)
select
  p.id as user_id,
  lower(
    coalesce(
      nullif(trim(ul.username), ''),
      split_part(p.email, '@', 1),
      'user_' || replace(p.id::text, '-', '')
    )
  ) as username,
  lower(p.email) as email
from public.profiles p
left join public.user_logins ul on ul.id = p.id
where p.email is not null and p.email <> ''
on conflict (user_id) do update
set
  username = excluded.username,
  email = excluded.email,
  updated_at = now();

-- Resolve username/email conflicts deterministically.
with dupes as (
  select user_id, username,
         row_number() over (partition by username order by created_at, user_id) as rn
  from public.user_credentials
)
update public.user_credentials uc
set username = uc.username || '_' || substr(replace(uc.user_id::text, '-', ''), 1, 6),
    updated_at = now()
from dupes d
where uc.user_id = d.user_id
  and d.rn > 1;

with dupes as (
  select user_id, email,
         row_number() over (partition by email order by created_at, user_id) as rn
  from public.user_credentials
)
update public.user_credentials uc
set email = split_part(uc.email, '@', 1)
            || '+' || substr(replace(uc.user_id::text, '-', ''), 1, 6)
            || '@' || split_part(uc.email, '@', 2),
    updated_at = now()
from dupes d
where uc.user_id = d.user_id
  and d.rn > 1;

-- 5) Compatibility RPC for username -> email lookups.
create or replace function public.get_email_by_username(input_username text)
returns text
language sql
stable
as $$
  select uc.email
  from public.user_credentials uc
  where lower(uc.username) = lower(input_username)
  limit 1
$$;

-- 6) Optional denormalized state fetch for app bootstrap.
create or replace function public.get_user_state(input_user_id uuid)
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'user_id', input_user_id,
    'profile', (
      select to_jsonb(p.*)
      from public.profiles p
      where p.id = input_user_id
      limit 1
    ),
    'reminders', coalesce((
      select jsonb_agg(to_jsonb(r.*) order by r.created_at desc)
      from public.medication_reminders r
      where r.user_id = input_user_id
    ), '[]'::jsonb)
  )
$$;

-- 7) Lock down old plain-text password column if it exists.
-- Keep table for compatibility mapping only.
alter table if exists public.user_logins
  add column if not exists email text;

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public'
      and table_name='user_logins'
      and column_name='password_plain'
  ) then
    update public.user_logins
    set password_plain = '[REDACTED_MIGRATED]'
    where password_plain is not null
      and password_plain <> '[REDACTED_MIGRATED]';
  end if;
exception
  when undefined_table then null;
end $$;

commit;
