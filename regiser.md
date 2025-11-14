create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text unique,
  full_name text,
  phone text,
  role text default 'user',
  metadata jsonb,
  created_at timestamptz default now()
);

create index if not exists idx_profiles_email on public.profiles (email);

alter table public.profiles enable row level security;

create policy "Profiles - select own" on public.profiles
  for select using (auth.uid() = id);

create policy "Profiles - insert own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "Profiles - update own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);