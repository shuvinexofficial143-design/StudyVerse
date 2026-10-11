# StudyVerse Chat ID Backend — Android

## User flow

Each phone opens the private space, enters a simple **My Chat ID** such as `alex143` and presses **Create ID**. The other person does the same with a different ID. Enter the other person's short ID once, press **Start Chat**, and exchange text, photos and voice notes. No public sign-up form, email verification, invitation, QR, or call feature.

The app uses an anonymous Appwrite session behind the scenes. Chat IDs must be 3–30 lowercase letters, numbers, underscores or hyphens; the first character must be a letter. IDs are unique and case-insensitive (entered ID is converted to lowercase). Each ID is reserved as a row named `user_<chat-id>` in the existing Private Messages table. The ID profile row is readable to other authenticated Appwrite users for lookup; message rows are readable only by the two participant Appwrite user IDs. Clearing app data or reinstalling can lose the anonymous account, ID access and chat history.

## Appwrite project (already created, separate from Supabase production)

- Endpoint: `https://sgp.cloud.appwrite.io/v1`
- Project: `6acb25f9002eed3e32d5`
- TablesDB database: `6acb26b800128ccfb9b7`
- Private Messages table: `6acb27370006d588e3f4`
- Target private media bucket: `studyverse-private-media` (create before sending photos/voice notes)

## One-time Appwrite Console setup — required

1. **Apps > Add Platform > Android**, register exact Package Name `com.studyverse.app.studyverse`. Without this Appwrite returns **Invalid Origin** when creating IDs. Editing the Flutter APK alone cannot override this server-side platform restriction.
2. **Auth > Settings > Anonymous = ON**.
3. **Databases > StudyVerseDB > Private Messages > Security**: Row Level Security ON and save. **Table permissions: Users CREATE only**. Do not add table-level READ, UPDATE, DELETE for Users or Any, because these would expose private chat rows. Message rows use `Permission.read(Role.user(senderUid))` and `Permission.read(Role.user(recipientUid))`. ID profile rows use `Permission.read(Role.users())` only so a phone can resolve another person's short ID with `getRow`.
4. The table already has the fields: `sender_id` String(64) required; `kind` String(12) required; `body` String(4000) optional; `file_id` String(64) optional; `duration_seconds` Integer optional (1–120). Profile rows use `kind='profile'`; text/image/voice are messages. **No extra table or columns are required**.
5. **Storage**: create private `studyverse-private-media` bucket; File Security ON, limit 10 MiB, allowed images JPEG/PNG/WebP and M4A/AAC audio. **Bucket CREATE only for Users**, no bucket READ or permissions for Any. Each uploaded media file is readable only by the two message participants.
6. Validate with two real phones and with an unrelated third anonymous account. Third account must not be able to read message rows or files. Verify screenshots, app switching, sending, receiving, photo download, voice note playback and saved ID after restart.

## Important limitations

- Chat is **not end-to-end encrypted**. Appwrite project administrators can access server-side message contents.
- There is no account recovery for anonymous identities; an ID can become inaccessible if app data/session is lost.
- App registration, Permissions and Storage must be set in Appwrite Console. Creating only the APK does not finish the backend.
- The `sender_id` column is client supplied, so it is not cryptographically verified. A server-side Appwrite Function to bind it to the actual session would be needed for strong sender authentication and abuse prevention.
- The private chat UI has no automatic exit on screenshot or temporary backgrounding. Android screenshots and screen recording are allowed across the whole app by owner request.
- The app is private-use only. The existing five-column table and anonymous flow are not a hardened public messaging product.
- Do not change any other user's Supabase projects. Release APK must be built only with explicit owner permission.
