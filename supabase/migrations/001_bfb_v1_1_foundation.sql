-- Bars From Behind v1.1 foundation
-- Run in Supabase SQL Editor on a new project.
create extension if not exists pgcrypto;

create type public.bfb_role as enum ('artist_rep','temporary_manager','admin');
create type public.facility_status as enum ('research','review','verified','unavailable');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role public.bfb_role not null default 'artist_rep',
  created_at timestamptz not null default now()
);

create table public.launch_cities (
  id uuid primary key default gen_random_uuid(),
  city text not null,
  state text not null,
  area_codes text[] not null default '{}',
  active boolean not null default true,
  unique(city,state)
);

create table public.facilities (
  id uuid primary key default gen_random_uuid(),
  launch_city_id uuid references public.launch_cities(id) on delete set null,
  name text not null,
  state text not null,
  county text,
  phone_provider text,
  compatibility public.facility_status not null default 'research',
  notes text,
  last_verified_at timestamptz
);

create table public.artists (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references auth.users(id) on delete cascade,
  stage_name text not null,
  legal_name text,
  facility_id uuid references public.facilities(id) on delete set null,
  artist_code bigint unique check (artist_code between 100000 and 999999),
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table public.manager_assignments (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.artists(id) on delete cascade,
  manager_user_id uuid not null references auth.users(id) on delete cascade,
  starts_at timestamptz not null default now(),
  expires_at timestamptz not null,
  permissions jsonb not null default '{"projects":"view","releases":"submit","earnings":"view"}',
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  check (expires_at > starts_at)
);

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_user_id uuid references auth.users(id) on delete set null,
  artist_id uuid references public.artists(id) on delete set null,
  action text not null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

insert into public.launch_cities(city,state,area_codes) values
('Los Angeles','CA',array['213','323','424']),
('Houston','TX',array['713','281','832']),
('Dallas–Fort Worth','TX',array['214','469','972','817']),
('Phoenix','AZ',array['602','480','623']),
('Chicago','IL',array['312','773']),
('Miami','FL',array['305','786']),
('Atlanta','GA',array['404','470','678']),
('New York City','NY',array['212','347','646','718']),
('Memphis','TN',array['901']),
('New Orleans','LA',array['504'])
on conflict do nothing;

alter table public.profiles enable row level security;
alter table public.launch_cities enable row level security;
alter table public.facilities enable row level security;
alter table public.artists enable row level security;
alter table public.manager_assignments enable row level security;
alter table public.audit_logs enable row level security;

create policy "public can read active launch cities" on public.launch_cities for select using (active = true);
create policy "authenticated can read facilities" on public.facilities for select to authenticated using (true);
create policy "users read own profile" on public.profiles for select to authenticated using (id = auth.uid());
create policy "users update own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "owners read artists" on public.artists for select to authenticated using (owner_user_id = auth.uid());
create policy "owners create artists" on public.artists for insert to authenticated with check (owner_user_id = auth.uid());
create policy "owners update artists" on public.artists for update to authenticated using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());
create policy "assigned managers read assignments" on public.manager_assignments for select to authenticated
using (manager_user_id = auth.uid() and revoked_at is null and now() < expires_at);

-- Admin policies should be added with a server-controlled admin claim or dedicated admin table.
-- Do not allow a browser user to promote their own role to admin.
