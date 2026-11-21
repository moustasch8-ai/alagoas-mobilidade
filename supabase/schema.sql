-- Alagoas Mobilidade: schema inicial (executado no projeto Supabase)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'passenger' check (role in ('passenger','driver')),
  role_requested text not null default 'passenger' check (role_requested in ('passenger','driver')),
  created_at timestamptz not null default now()
);
create table if not exists public.rides (
  id uuid primary key default gen_random_uuid(),
  passenger_id uuid not null references auth.users(id) on delete cascade,
  driver_id uuid references auth.users(id) on delete set null,
  origin text not null, destination text not null, city text not null, notes text,
  status text not null default 'requested' check (status in ('requested','accepted','in_progress','completed','cancelled')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists rides_passenger_created_idx on public.rides(passenger_id, created_at desc);
create index if not exists rides_driver_created_idx on public.rides(driver_id, created_at desc);
create index if not exists rides_open_created_idx on public.rides(status, created_at desc) where driver_id is null;
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  -- Metadados de cadastro são editáveis pelo usuário: nunca conceda papel de motorista com base neles.
  insert into public.profiles (id, full_name, role, role_requested)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''), 'passenger',
    case when new.raw_user_meta_data ->> 'role' = 'driver' then 'driver' else 'passenger' end)
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
alter table public.profiles enable row level security;
alter table public.rides enable row level security;
grant select, insert on public.profiles to authenticated;
grant select, insert on public.rides to authenticated;
drop policy if exists "Users read own profile" on public.profiles;
create policy "Users read own profile" on public.profiles for select to authenticated using ((select auth.uid()) = id);
drop policy if exists "Users update own profile name" on public.profiles;
create policy "Users update own profile name" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
revoke update on public.profiles from authenticated;
grant update (full_name) on public.profiles to authenticated;
drop policy if exists "Passengers create own rides" on public.rides;
create policy "Passengers create own rides" on public.rides for insert to authenticated with check ((select auth.uid()) = passenger_id and driver_id is null and status = 'requested');
drop policy if exists "Passengers and assigned drivers read rides" on public.rides;
create policy "Passengers and assigned drivers read rides" on public.rides for select to authenticated using (
 (select auth.uid()) = passenger_id or (select auth.uid()) = driver_id
 or (status = 'requested' and driver_id is null and exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'driver'))
);
drop policy if exists "Passengers cancel own requested rides" on public.rides;
create policy "Passengers cancel own requested rides" on public.rides for update to authenticated
using ((select auth.uid()) = passenger_id and status = 'requested')
with check ((select auth.uid()) = passenger_id and status = 'cancelled' and driver_id is null);
drop policy if exists "Drivers accept open rides" on public.rides;
create policy "Drivers accept open rides" on public.rides for update to authenticated
using (status = 'requested' and driver_id is null and exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'driver'))
with check (driver_id = (select auth.uid()) and status = 'accepted' and passenger_id <> (select auth.uid()));
revoke update on public.rides from authenticated;
grant update (status, driver_id) on public.rides to authenticated;