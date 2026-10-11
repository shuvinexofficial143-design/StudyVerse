# StudyVerse — Android study + private space

[![Android APK](https://github.com/shuvinexofficial143-design/StudyVerse/actions/workflows/android.yml/badge.svg)](https://github.com/shuvinexofficial143-design/StudyVerse/actions/workflows/android.yml)

A Flutter Android study app with an offline dashboard, subject-based notes, a ten-question quiz, local progress and a PIN-gated private messaging area.

## Current features

- Home: subject cards, quick access to notes and quizzes
- Study: locally persisted notes, add/view/delete, subject filters
- Quiz: ten answerable questions and result
- Progress: saved score and daily tasks
- Settings: access to the private Resource Vault
- Vault: separate six-digit device PIN, automatic exit on app background
- Chat: two-person, Supabase-backed real-time messaging **after** dedicated backend configuration
- Privacy defaults: no notification permission or push notifications, chat content not shown on normal study pages, Android screenshot/app-preview blocking via FLAG_SECURE

**Important:** Hiding a chat when leaving the page does not delete messages from the backend. When unlocked again, authorised users can retrieve history. The current server-side chat is **NOT end-to-end encrypted**: Supabase database administrators could access plaintext. The PIN is local access protection, **not** a substitute for encryption and strong authentication. No app can guarantee that a person looking at an unlocked phone will not see it.

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

GitHub Actions **Android APK** also builds the APK on every push to main. Open **Actions → Android APK → latest successful run → Artifacts** and download StudyVerse-Android-APK. Do not install until the build succeeded and the APK was tested. The default workflow runs **without** backend credentials: offline study features work, private chat displays a setup notice.

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

- [x] Initial Flutter UI pages
- [x] Offline notes, quiz and tasks
- [x] Local PIN gate and quick-exit navigation
- [x] Supabase SQL schema and live chat client code
- [ ] Connect a dedicated backend and test on two real Android devices
- [ ] Review encryption, screen locking, PIN lockout persistence and backups
- [ ] Add flashcards, PDF reader, chapter quizzes and study planning
- [ ] Verify app signing and installable release builds on physical devices
