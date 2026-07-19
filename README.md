# AURA — AI Companion (Phase 1 Mobile Client)

AURA is a persistent AI companion designed to live across mobile, desktop,
Raspberry Pi and robotics. This repository is the **first client of the AURA
brain**: a production-quality Flutter app built to grow into a multi-platform
AI operating system.

> Not a chat app. Not a ChatGPT clone. A calm, minimal, personal companion OS.

---

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (stable), Material 3 |
| State | Riverpod (+ hooks_riverpod) |
| Navigation | go_router |
| Networking | Dio (REST) · web_socket_channel |
| Models | freezed + json_serializable (build_runner) |
| UI | flutter_hooks · responsive_framework · google_fonts (Inter) · flutter_markdown · shimmer |
| Device | speech_to_text · flutter_tts · flutter_local_notifications · flutter_secure_storage · google_sign_in · connectivity_plus · shared_preferences |

## Architecture

Feature-first Clean Architecture. No business logic inside widgets;
dependencies are injected via Riverpod providers.

```
lib/
├── app.dart                  # MaterialApp.router, themes, responsive shell
├── main.dart                 # bootstrap + provider overrides
├── core/
│   ├── config/               # Env (--dart-define) + app metadata
│   ├── errors/               # AppFailure
│   ├── providers/            # DI: prefs, secure storage, Dio, services
│   ├── services/             # ApiClient, WebSocket, speech, notifications, storage
│   ├── shared/widgets/       # Design system (buttons, cards, dialogs, states…)
│   ├── theme/                # Colors / typography / spacing / ThemeData
│   └── utils/                # time formatting helpers
├── routes/app_router.dart    # go_router + auth redirects
└── features/
    ├── splash/               # presentation
    ├── auth/                 # Google sign-in + "skip for now" (guest)
    ├── home/                 # dashboard (greeting, summary, weather, goals,
    │                         #   events, memories, conversations, quick actions)
    ├── conversation/         # chat UI, streaming replies, markdown, typing dots
    ├── voice/                # full-screen voice mode (orb, waveform, interrupt)
    ├── briefing/             # morning briefing
    ├── memory/               # searchable memory timeline
    ├── goals/  calendar/     # shared providers consumed by home & briefing
    └── settings/             # theme, voice, language, notifications, dev mode
```

Every feature follows `presentation/ · application/ · domain/ · data/`.

## Screens (Phase 1)

Splash · Authentication (Google / skip) · Home · Conversation (streaming,
markdown, typing indicator) · Voice Mode (listening/speaking animations,
interrupt) · Daily Briefing · Memory Timeline (search) · Settings.

## Backend integration

A FastAPI backend is assumed. Repositories are interface-bound; while
`USE_MOCK_API=true` (default) they serve realistic dummy data, with
`TODO(backend)` markers where each real endpoint plugs in:

`POST /chat` · `POST /voice` · `GET /context` · `GET /memory` ·
`GET /briefing` · `GET /goals` · `GET /calendar` · `POST /settings`

**No URLs are hardcoded.** Configuration comes from `--dart-define`:

| Define | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | `https://api.aura.example.com` | REST base URL |
| `WS_BASE_URL` | `wss://api.aura.example.com/ws` | WebSocket base URL |
| `USE_MOCK_API` | `true` | Mock vs. real repositories |

---

## Building the APK — in the cloud (no local installs)

You don't need Flutter, Android SDK or Gradle on your machine.
Two pipelines are included; pick either.

> The Android platform folder is intentionally **not committed** — the
> pipeline runs `flutter create` on the latest stable Flutter, patches
> `AndroidManifest.xml` (RECORD_AUDIO / POST_NOTIFICATIONS / speech & TTS
> queries) via `tool/patch_android_manifest.py`, runs `build_runner`
> (freezed/json), then builds a release APK split per ABI.

### Option A — GitHub Actions (`.github/workflows/build-apk.yml`)

1. Push this repository to GitHub.
2. In the repo, open **Actions → Android APK → Run workflow**
   (optionally set `api_base_url` / `use_mock_api`).
3. When the run finishes, download the **`aura-apk`** artifact — it
   contains `app-armeabi-v7a`, `app-arm64-v8a` and `app-x86_64` release APKs.
   Every push to `main` also builds automatically.

### Option B — Codemagic (`codemagic.yaml`)

1. Sign in at [codemagic.io](https://codemagic.io) (free tier) and add the repo.
2. Choose the **Android APK** workflow from `codemagic.yaml`
   (edit `API_BASE_URL` / `USE_MOCK_API` in the `environment.vars` section).
3. Start the build; download the APKs from the build's **Artifacts** section.

### Optional: Project IDX (browser IDE)

Import the repo at [idx.google.com](https://idx.google.com) (Flutter template),
then run the same commands as below — the toolchain is preinstalled in the
cloud VM.

### Optional: local build

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --dart-define=API_BASE_URL=https://your.api
```

---

## Design language

Dark-mode-first (`#0D1117` background, `#161B22` cards, `#5B8CFF` primary,
`#6EE7F9` accent), Inter typography, generous radii, hairline borders and
subtle motion — closer to an operating system than a messenger.

## Roadmap notes / known TODOs

- Real auth: exchange the Google `idToken` with the backend for a session token.
- Streaming chat: upgrade `ApiChatRepository` to SSE or the WebSocket channel.
- Scheduled morning-briefing notification (needs `timezone` + Android
  core-library desugaring).
- Voice turn loop over `POST /voice` + WebSocket for barge-in.
