-- StudyVerse: run in a NEW, dedicated Supabase project only.
-- Create two confirmed users in Authentication before pairing them.
create extension if not exists pgcrypto;

create table if not exists public.study_pairs (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references auth.users(id) on delete cascade,
  user_b uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint distinct_members check (user_a <> user_b),
  constraint unique_pair unique (user_a, user_b)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  pair_id uuid not null references public.study_pairs(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(btrim(body)) between 1 and 4000),
  created_at timestamptz not null default now()
);

create index if not exists messages_pair_created_idx
on public.messages (pair_id, created_at);

alter table public.study_pairs enable row level security;
alter table public.messages enable row level security;

revoke all on public.study_pairs from anon;
revoke all on public.messages from anon;

drop policy if exists "Members can see their pair" on public.study_pairs;
create policy "Members can see their pair" on public.study_pairs
for select to authenticated
using (auth.uid() = user_a or auth.uid() = user_b);

drop policy if exists "Members can read their messages" on public.messages;
create policy "Members can read their messages" on public.messages
for select to authenticated
using (
  exists (
    select 1 from public.study_pairs p
    where p.id = pair_id
      and (p.user_a = auth.uid() or p.user_b = auth.uid())
  )
);

drop policy if exists "Members can send to their pair" on public.messages;
create policy "Members can send to their pair" on public.messages
for insert to authenticated
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.study_pairs p
    where p.id = pair_id
      and (p.user_a = auth.uid() or p.user_b = auth.uid())
  )
);

-- No client UPDATE or DELETE policy: messages cannot be modified by app users.
-- Enable realtime on messages:
do $$ begin
  alter publication supabase_realtime add table public.messages;
exception when duplicate_object then null;
end $$;

-- After creating BOTH auth users, replace placeholders with their UUIDs:
-- insert into public.study_pairs(user_a, user_b)
-- values ('FIRST_USER_UUID', 'SECOND_USER_UUID');
--
-- Privacy note: RLS protects access; the server stores message text in
-- readable form. This is NOT end-to-end encryption.
