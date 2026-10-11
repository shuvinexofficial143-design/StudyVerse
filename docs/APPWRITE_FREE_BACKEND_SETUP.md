# StudyVerse Private — simple Chat ID backend

The owner requested **no email, password, QR, invitation, or team membership** for end users. Appwrite's anonymous session is used only behind the scenes. On each phone, tapping **Create My Chat ID** generates an Appwrite user ID. One person shares the ID with the other (outside the app); the sender pastes it once, taps Start Chat and sends text, image or voice notes. Receiving a first message automatically recognises that sender as the partner and opens their private conversation. The chosen peer is stored locally on that phone.

The previously created Appwrite Team is not used and requires no invitations. Existing Open Chet and Instagram Supabase projects must remain unchanged.

## Project already created in Singapore

- Endpoint: `https://sgp.cloud.appwrite.io/v1`
- Project ID: `6acb25f9002eed3e32d5`
- TablesDB database ID: `6acb26b800128ccfb9b7`
- Private Messages table ID: `6acb27370006d588e3f4`
- Target Storage bucket ID: `studyverse-private-media` (still must be created)

Project, database and table IDs are **public configuration identifiers, not API secrets**. All five chat columns are present in the table: `sender_id` (string 64, required), `kind` (string 12, required), `body` (string 4000, optional), `file_id` (string 64, optional), and `duration_seconds` (integer 1–120, optional).

## Required dashboard configuration before use

1. **Auth > Settings / Policies**: enable **Anonymous** sign-in. No login or invitation is shown inside StudyVerse.
2. **Apps**: register the Flutter Android platform using the actual installed Android application ID. The workflow generates Android scaffolding with `flutter create . --platforms android --org com.studyverse.app`; inspect the generated `applicationId`, which is normally `com.studyverse.app.studyverse`.
3. **Databases > StudyVerseDB > Private Messages > Security**: enable **Row Security**, save it. At the table level, grant **CREATE only** to `Users` (this includes anonymous sessions). **Never grant READ, UPDATE or DELETE at table level to Users, Any or Guests**. Rows created by the app grant **READ only to sender and intended recipient** via `Permission.read(Role.user(uid))`. Without this, anyone can view all messages. For stricter anti-impersonation and spam prevention, validate sender + target on an Appwrite Function; client-supplied `sender_id` alone must not be trusted as verified identity.
4. **Storage**: create **private** bucket `studyverse-private-media`; enable **File Security**, at-rest encryption, file max size 10 MiB. Allow MIME types JPEG, PNG, WebP and audio/mp4 (AAC/M4A).
5. **Bucket Permissions**: grant **CREATE only** to `Users`, including anonymous sessions. No bucket-level READ/UPDATE/DELETE for Users, Any or Guests. Files created by the app grant READ to the sender and recipient and DELETE to the sender.
6. On an Android device, open the Vault, tap **Create My Chat ID**, then copy the server-generated Chat ID and give it to the other phone. The receiver can also create its ID independently. The sender pastes the receiver's ID and sends the first message; the receiver will show the incoming conversation.
7. Test *two phones*, and separately test an unrelated third account. Confirm it cannot read either person's message rows or files. Tests must include relaunch, incoming message auto-detection, image upload/download, microphone permissions and voice playback.
8. **Only build an APK after the owner explicitly asks for one.** GitHub push validation runs analyse and tests but not release APK.

## Important limitations and security

- Appwrite **anonymous accounts have no self-service recovery**. Clearing app data, uninstalling, losing the device or expiration of its session may make the Chat ID and its old messages inaccessible. Reinstalling may create a *different* ID. Do not promise recovery without adding an account-recovery design later.
- A fixed/secret APK is not an access control mechanism. The third-account test remains required.
- Messages are **not end-to-end encrypted**. Private Appwrite permissions restrict normal users; server/project administrators can still access stored data.
- A client-supplied sender ID may be spoofed by modified apps. For verified sender identity and anti-spam controls, use a server-side Appwrite Function tied to the calling session.
- Since one phone is intended to chat with one other ID only, locally store a single partner. The present five-column table has no dedicated `recipient_id`, so a fully reliable multi-contact inbox will require a schema upgrade. Do not expose that as a finished feature.
- The account's Anonymous/Auth settings, Storage bucket and table permissions are **not automatically configured from GitHub**. Live backend testing remains outstanding.
- Voice/image sending only, **no audio calling/video calling/video file sharing**.
