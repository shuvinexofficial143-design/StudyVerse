# StudyVerse — Android study + private space

[![Android APK](https://github.com/shuvinexofficial143-design/StudyVerse/actions/workflows/android.yml/badge.svg)](https://github.com/shuvinexofficial143-design/StudyVerse/actions/workflows/android.yml)

A Flutter Android study app tailored to **NIOS Senior Secondary (Class 12)** learners, with editable registered subjects, subject notes, original law/humanities/language practice questions, local study progress, an advocate career guide and a protected private messaging area.

## Current features

- Home: NIOS Class 12 overview and advocate career path
- Study: select actual NIOS subjects, view official Law (338) chapter titles, add/edit/view/delete offline notes, open official NIOS subject materials, import offline PDF documents, create practice flashcards and schedule weekly revision sessions
- Quiz: sample **original practice questions** by NIOS-related subject (not official past papers), immediate result, correct-answer explanations and local attempt history
- Progress: saved quiz score and revision tasks
- Android back: navigates to the previous quiz question/previous tab, with a confirmation before leaving Home
- Settings: access to a protected Resource Vault
- Vault: accepts an alphanumeric **6–32 character access code**. Set your own access code (e.g., your chosen private phrase) the first time you open the vault. It is stored using Android secure storage, not hardcoded in this public repository.
- Chat: soft pink heart-themed private area with automatic lock; Appwrite **Create My Chat ID** (anonymous server identity), message a partner's Chat ID, incoming chat auto-detection, text, private image sharing and voice notes. No email, invitation, QR or calls. Requires completing Appwrite Console permissions and Storage setup and live Android tests.
- Privacy defaults: no push chat notifications, and Android screenshot / app-preview protection

**Important: NIOS Class 12 subject choice must match the learner's actual registration.** The available list is not evidence of the subjects she enrolled in. Introduction to Law (338) is offered as a subject, but is **not automatically required** for an advocate career. See the official [NIOS subject list](https://rcpune.nios.ac.in/senior-secondary-courses-material.html) and [Introduction to Law e-content](https://digital.nios.ac.in/topic.php?id=338en).

**Security limitations:** Leaving chat does not delete its server history. The current server-side messages are **not end-to-end encrypted**: the database operator can read plaintext. A local access code is not a substitute for server authentication or client-side message encryption. The passcode is set at first use and is *not* automatically preloaded from the code. This is a testing build, not a security-audited app.

**Study file privacy:** imported PDFs, notes, flashcards and study schedules currently persist locally on that Android device; there is no cross-device study data sync or automatic cloud backup. PDFs must be obtained separately from official sources or user-supplied files. The small sample MCQ bank is not a complete NIOS course and must not be represented as one.

**Build policy:** Pushing to main triggers `flutter analyze` and `flutter test` only. An APK is built **only** on a manually dispatched GitHub Actions run. Do not create an APK until requested.

## Build locally

Install Flutter stable SDK, Android SDK and VS Code with Flutter/Dart extensions.

```bash
git clone https://github.com/shuvinexofficial143-design/StudyVerse.git
cd StudyVerse
flutter create . --platforms android --org com.studyverse.app
flutter pub get
flutter run
```

Create the Android APK:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

GitHub Actions **StudyVerse Validation (Manual APK)** validates every push, but makes an APK only when manually dispatched. Open **Actions → Android APK → latest successful run → Artifacts** and download StudyVerse-Android-APK. Do not install until the build succeeded and the APK was tested. Appwrite's public project/database/table IDs are preconfigured from the owner's new Singapore project; the separate Storage bucket, row permissions, Android platform registration and anonymous-auth policy still need setup. No administrator API key is embedded.

## Standalone Appwrite Chat ID backend

The StudyVerse Private Appwrite project is **independent** of Open Chet and
Instagram DM Supabase projects. Its Project, Database, and Table identifiers
are embedded as **public client configuration**, not privileged API keys.

The app's intended setup is:

1. On the first device, open the private Vault and press **Create My Chat ID**.
   An anonymous Appwrite user/session is created. No email, password, QR or
   invitation is required for that user.
2. On the second device, create its own Chat ID the same way.
3. Paste the second person's ID once and send the first message. The recipient
   sees incoming chat automatically, without manually entering your ID.
4. Chat supports text, images and voice notes only, with per-user row/file
   read permissions. No calling and no push notifications.

Before testing, complete the official Console setup documented in
**[docs/APPWRITE_FREE_BACKEND_SETUP.md](docs/APPWRITE_FREE_BACKEND_SETUP.md)**:
enable anonymous Auth, grant users table CREATE only (no table READ), enable
row security, create private encrypted Storage with file security and
CREATE-only bucket permission, register the Android package name.

**Limitations:** Anonymous IDs can be lost on reinstall, local data loss or
expired sessions. There is no recovery flow. Client-supplied sender IDs need
server-side verification for hardened anti-impersonation; this remains
unimplemented. There is no end-to-end encryption. Do not consider private
messaging production-ready before testing data isolation on two phones and
against an unrelated third account.

The legacy Supabase schema/client is retained as an unused alternative;
do not run it against production databases.

## Roadmap

- [x] NIOS Class 12 dashboard and subject picker
- [x] Offline notes with editing, NIOS practice quiz with explanations/history, flashcards, weekly planner and local PDF import
- [x] Local alphanumeric access-code gate, safe Android Back and quick exit
- [x] Appwrite Chat ID UI/client for two phones and private text/photo/voice message permissions (source only)
- [ ] Finish Appwrite anonymous Auth, private Storage and permissions; test on two actual Android devices with a third unauthorized account
- [ ] Review encryption, screen locking, PIN lockout persistence and backups
- [ ] Add larger official syllabus-aligned banks, complete subject chapter study notes, previous papers/TMA support and real-device usability tests
- [ ] Verify app signing and installable release builds on physical devices
