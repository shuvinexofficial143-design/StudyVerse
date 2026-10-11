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
- Chat: soft pink heart-themed background, automatic lock on backgrounding and quick return to study; encrypted-at-rest local access code; two-user Supabase real-time messages **after** a dedicated backend is configured
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

GitHub Actions **StudyVerse Validation (Manual APK)** validates every push, but makes an APK only when manually dispatched. Open **Actions → Android APK → latest successful run → Artifacts** and download StudyVerse-Android-APK. Do not install until the build succeeded and the APK was tested. The default workflow runs **without** backend credentials: offline study features work, private chat displays a setup notice.

## Dedicated Supabase database for two users

1. Create a **new** Supabase project exclusively for StudyVerse (do not reuse production projects).
2. In Supabase SQL Editor run `supabase/schema.sql`. It creates `study_pairs`, `messages`, RLS and realtime.
3. In Authentication, create two consenting user accounts. Disable public sign-up for this private use case.
4. Insert the two Auth user UUIDs into `study_pairs` using the commented example at the bottom of the schema.
5. Set the project's URL and **publishable/anon** key as Flutter build defines. Do **not** use the service-role/secret key in the app.

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY
```

For a configured release APK:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY
```

The Supabase anon/publishable key is client-visible by design; RLS is what restricts data to the two approved members. Never commit passwords, PINs, message dumps, private certificates or service-role keys. For stronger privacy before real-world use, add a reviewed end-to-end encryption protocol and a proper account/session threat-model review.

## Roadmap

- [x] NIOS Class 12 dashboard and subject picker
- [x] Offline notes with editing, NIOS practice quiz with explanations/history, flashcards, weekly planner and local PDF import
- [x] Local alphanumeric access-code gate, safe Android Back and quick exit
- [x] Supabase SQL schema and live chat client code
- [ ] Confirm learner's enrolled NIOS subjects; connect a dedicated backend and test on two real Android devices
- [ ] Review encryption, screen locking, PIN lockout persistence and backups
- [ ] Add larger official syllabus-aligned banks, complete subject chapter study notes, previous papers/TMA support and real-device usability tests
- [ ] Verify app signing and installable release builds on physical devices
