-- 灵感日记 Supabase schema
-- Run in Supabase SQL Editor. RLS ensures users can access only their own document.
create table if not exists public.user_documents (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.user_documents enable row level security;
revoke all on public.user_documents from anon;
grant select, insert, update, delete on public.user_documents to authenticated;
drop policy if exists "read own document" on public.user_documents;
create policy "read own document" on public.user_documents for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "insert own document" on public.user_documents;
create policy "insert own document" on public.user_documents for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "update own document" on public.user_documents;
create policy "update own document" on public.user_documents for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists "delete own document" on public.user_documents;
create policy "delete own document" on public.user_documents for delete to authenticated using ((select auth.uid()) = user_id);
