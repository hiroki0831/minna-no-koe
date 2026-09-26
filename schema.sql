-- Supabase > SQL Editor で実行。RLSで組織別のアクセスを強制。
create extension if not exists pgcrypto;
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  kind text not null check (kind in ('company','ethics')),
  created_at timestamptz not null default now()
);
create table if not exists public.memberships (
  org_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('member','admin')),
  primary key(org_id,user_id)
);
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organizations(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (length(title) between 1 and 200),
  summary text not null check (length(summary) between 1 and 4000),
  original_text text not null check (length(original_text) between 1 and 20000),
  main_category text not null,
  sub_category text not null,
  topic text not null,
  status text not null default 'new' check (status in ('new','review','accepted','done')),
  created_at timestamptz not null default now()
);
create index if not exists posts_org_created on public.posts(org_id,created_at desc);
alter table public.organizations enable row level security;
alter table public.memberships enable row level security;
alter table public.posts enable row level security;
create policy "members view their memberships" on public.memberships for select to authenticated using (user_id=(select auth.uid()));
create policy "members view their organizations" on public.organizations for select to authenticated using (id in (select org_id from public.memberships where user_id=(select auth.uid())));
create policy "members view their org posts" on public.posts for select to authenticated using (org_id in (select org_id from public.memberships where user_id=(select auth.uid())));
create policy "members post in their org" on public.posts for insert to authenticated with check (author_id=(select auth.uid()) and org_id in (select org_id from public.memberships where user_id=(select auth.uid())) and status='new');
-- 所属情報の登録はSupabase管理画面(SQL Editor)だけで行う。公開クライアントからの変更を許可しない。
insert into public.organizations(name,kind) values ('会社','company'),('倫理法人会','ethics') on conflict (name) do nothing;
