# StudyVerse: photos and voice notes (no calling)

Scope: only text, gallery photos and microphone voice notes in the private one-to-one chat. **No voice calls, video calls or video sharing.** APK generation remains manual.

## Storage location

- `public.messages`: message type, optional text, media object reference, MIME type, voice duration.
- `storage.buckets`: a **private**, not public, bucket named `studyverse-private-media`.
- `storage.objects`: object names follow `PAIR_UUID/SENDER_UUID/UNIQUE_NAME.ext`.
- `public.study_pairs` + RLS: only the two participating authenticated users have access to that pair and its files.
- Signed image/audio URLs expire after 120 seconds; URLs are never saved in the message table.

Images: gallery, JPEG/PNG/WebP, maximum 10 MB after selection.
Voice: AAC in M4A container, minimum 1 second, maximum 120 seconds, maximum 10 MB.
The microphone is used only when a person taps record. An unfinished recording can be discarded.

## Setting up the backend (NOT DONE YET)

Create a **dedicated StudyVerse Supabase project** in the user's explicitly chosen organization. Do not reuse the existing production database for another app.

1. Run `supabase/schema.sql` first, then `supabase/media_migration.sql`.
2. Configure Supabase Authentication with exactly two approved accounts.
3. Pair those two accounts by inserting their authenticated user UUIDs in `public.study_pairs`. Do not put account credentials or the user UUIDs in GitHub.
4. Set the publishable key and Supabase URL via build configuration; never ship the service-role key in the APK.
5. Test image sending, audio record/playback, permission denial, image format mismatch, signed URL expiration and RLS isolation with two real Android devices.

## Limits and privacy

The stored photos, audio and messages are **not end-to-end encrypted**. A Supabase administrator with sufficient privileges can access them. The storage bucket is private to other app users but is not cryptographically opaque to the backend operator. Before personal use, perform privacy/security tests and ideally adopt a reviewed end-to-end encryption design.

The existing PIN/access-code is locally set when the user first unlocks the vault; it is not hardcoded. Gallery permissions and microphone prompts should be tested on actual Android versions. Text/photo/audio must remain hidden from the normal study UI and must not cause push notifications.
