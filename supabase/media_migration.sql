-- Run AFTER supabase/schema.sql in a NEW dedicated StudyVerse project.
-- Extend the two-person chat with image + voice notes only. NO calls.
-- Private storage and pair-scoped RLS are mandatory.
alter table public.messages alter column body drop not null;
alter table public.messages drop constraint if exists messages_body_check;
alter table public.messages
  add column if not exists message_type text not null default 'text',
  add column if not exists storage_path text,
  add column if not exists mime_type text,
  add column if not exists duration_seconds integer;

alter table public.messages
  drop constraint if exists messages_content_valid;
alter table public.messages
  add constraint messages_content_valid check (
    (
      message_type = 'text'
      and body is not null
      and char_length(btrim(body)) between 1 and 4000
      and storage_path is null and mime_type is null
      and duration_seconds is null
    )
    or (
      message_type = 'image'
      and body is null
      and storage_path is not null
      and mime_type in ('image/jpeg', 'image/png', 'image/webp')
      and duration_seconds is null
    )
    or (
      message_type = 'voice'
      and body is null
      and storage_path is not null
      and mime_type = 'audio/mp4'
      and duration_seconds between 1 and 120
    )
  );

alter table public.messages
  drop constraint if exists messages_storage_path_scoped;
alter table public.messages
  add constraint messages_storage_path_scoped check (
    storage_path is null or (
      storage_path like pair_id::text || '/' || sender_id::text || '/%'
      and char_length(storage_path) <= 200
    )
  );

grant select on table public.study_pairs to authenticated;
grant select, insert on table public.messages to authenticated;

-- Bucket maximum 10 MiB per object. Photos + voice recordings only.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('studyverse-private-media', 'studyverse-private-media',
        false, 10485760,
        array['image/jpeg', 'image/png', 'image/webp', 'audio/mp4'])
on conflict (id) do update
set public = false,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

-- The prefix is: <pair UUID>/<sender UUID>/<unique file name>.
-- SELECT permits both members of the pair to generate short-lived signed URLs.
drop policy if exists "StudyVerse paired members read media" on storage.objects;
create policy "StudyVerse paired members read media"
on storage.objects for select to authenticated
using (
  bucket_id = 'studyverse-private-media'
  and exists (
    select 1 from public.study_pairs p
    where p.id::text = (storage.foldername(name))[1]
      and (p.user_a = auth.uid() or p.user_b = auth.uid())
  )
);

-- INSERT permits only the authenticated member into their own sender prefix.
drop policy if exists "StudyVerse sender uploads media" on storage.objects;
create policy "StudyVerse sender uploads media"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'studyverse-private-media'
  and (storage.foldername(name))[2] = auth.uid()::text
  and exists (
    select 1 from public.study_pairs p
    where p.id::text = (storage.foldername(name))[1]
      and (p.user_a = auth.uid() or p.user_b = auth.uid())
  )
);

-- Permit a sender to clean up their own unsuccessful uploads only.
drop policy if exists "StudyVerse sender deletes own media" on storage.objects;
create policy "StudyVerse sender deletes own media"
on storage.objects for delete to authenticated
using (
  bucket_id = 'studyverse-private-media'
  and (storage.foldername(name))[2] = auth.uid()::text
  and exists (
    select 1 from public.study_pairs p
    where p.id::text = (storage.foldername(name))[1]
      and (p.user_a = auth.uid() or p.user_b = auth.uid())
  )
);
