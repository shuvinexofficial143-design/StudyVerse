# StudyVerse — separate Appwrite Cloud Free backend

The Supabase organization currently has its two free projects in use.
Do not create StudyVerse tables in **Open Chet** or **Instagram DM
Production**. Never change, pause, delete or migrate an old project.

## One-time Appwrite account setup (user action required)

1. Open https://cloud.appwrite.io/ and sign up or sign in.
2. Choose **Free** and create a new project named **StudyVerse Private**.
   Do not add a payment method or switch to Pro unless the owner explicitly
   approves the charges. The Free tier has resource caps.
3. Add the Flutter/Android platform, using the actual package/application ID
   produced by the Android build (currently `com.studyverse.app.studyverse`
   if generated with `--org com.studyverse.app`; verify the build manifest
   rather than assuming that this ID is final).
4. Under Auth, enable email/password logins and disable public account
   registration. Create **only the two approved users**, each with their
   own strong account password. Never embed passwords in the APK.
5. Create a Team ID (such as `studyversepair`) with only those two accounts.
   Finish any membership verification/acceptance. A user who is not a team
   member must be blocked from the chat.
6. Create a database (example ID `studyversedb`) with a TablesDB table
   (example ID `private_messages`). Define these columns:
   - `sender_id`: string, required, max 64
   - `kind`: string, required, max 12 (text / image / voice)
   - `body`: string, optional, max 4000
   - `file_id`: string, optional, max 64
   - `duration_seconds`: integer, optional
   `$createdAt` is an automatic Appwrite system field.
7. **Enable Row Security**. At table level grant CREATE only to
   `Role.team(teamId)`. Do **NOT** grant READ, UPDATE or DELETE at the
   table level, and grant nothing to `Role.any()` or all authenticated
   users. Each created message row grants read only to the private team.
   Disable unnecessary query access and consider a server-side validation
   function if broader membership or more features are introduced.
8. Create Storage Bucket (example ID `private_media`), turn on
   **File Security** and encryption-at-rest. Allow CREATE at bucket level
   to private team only. Do not grant bucket READ to any role.
   Each image/audio upload explicitly grants file-level READ to the team
   and DELETE to its creator. Keep limits under 10 MiB, allow JPEG/PNG/
   WebP and M4A audio, do not make it public.
9. Copy project endpoint URL, project ID, database ID, table ID, bucket ID,
   and Team ID. These are public identifiers, not credentials.
10. Configure the six `APPWRITE_*` build definitions below. Run
    `flutter analyze` and `flutter test`; run the APK build **only**
    after the user explicitly requests it. Test both phones with the
    approved users, then test a third unapproved user for access denial.

## Flutter build definitions

```bash
flutter run \
  --dart-define=APPWRITE_ENDPOINT=https://<REGION>.cloud.appwrite.io/v1 \
  --dart-define=APPWRITE_PROJECT_ID=<ID> \
  --dart-define=APPWRITE_DATABASE_ID=<ID> \
  --dart-define=APPWRITE_CHAT_TABLE_ID=<ID> \
  --dart-define=APPWRITE_MEDIA_BUCKET_ID=<ID> \
  --dart-define=APPWRITE_PRIVATE_TEAM_ID=<ID>
```

For GitHub's manual APK workflow, add matching GitHub repository variables:
`STUDYVERSE_APPWRITE_ENDPOINT`,
`STUDYVERSE_APPWRITE_PROJECT_ID`,
`STUDYVERSE_APPWRITE_DATABASE_ID`,
`STUDYVERSE_APPWRITE_CHAT_TABLE_ID`,
`STUDYVERSE_APPWRITE_MEDIA_BUCKET_ID`,
`STUDYVERSE_APPWRITE_PRIVATE_TEAM_ID`.

If these are absent, the normal study app remains functional and the
existing Supabase/no-backend path is unchanged. Nothing here has created an
Appwrite Cloud project; an owner must connect/authorize that external account.

## Security limitations

Permissions restrict app users; they do not provide end-to-end encryption.
Appwrite project administrators may be able to access stored data.
Use individual, verified accounts; disable public signup; test team and
file read policies with an unrelated third account. Voice/audio temp files
should be removed on closing the private screen. The Android Vault code
is a local app screen lock, not a substitute for server authorization.
Use a custom strong passcode, not the exact sample shown in past chats.

Never call or video call. Support only text, image and voice notes.
No push notifications. This repository must be private before sensitive
release material or real messages are introduced.

References:
- https://appwrite.io/docs/advanced/billing/free
- https://appwrite.io/docs/products/databases/tablesdb/permissions
- https://appwrite.io/docs/products/storage/permissions
- https://appwrite.io/docs/products/auth/teams
