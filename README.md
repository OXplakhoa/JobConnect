# JobConnect

AI-powered job matching app for Vietnamese students and fresh graduates.
Connects **Seekers** with **Recruiters** using pgvector similarity search and Gemini embeddings.

## Tech Stack

- **Frontend:** Flutter 3.x (Dart 3.x)
- **State:** Riverpod 2.x (`@riverpod` code generation)
- **Backend:** Supabase (Auth + PostgreSQL + Storage + Realtime)
- **AI:** Google Gemini API (embeddings + Flash explanations)
- **Architecture:** Clean Architecture (3-layer)

## Quick Start

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

See `.env.example` for required environment variables.

## Documentation

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Agent coding rules — architecture, naming, forbidden patterns |
| `CONTEXT.md` | Shared domain language — terms, relationships, naming conventions |
| `TASKS.md` | Feature checklist — current progress |
| `docs/BRIEF.md` | Full project spec — features, schema, tech stack |
| `docs/PRODUCT.md` | User personas, brand personality, design principles |
| `docs/DESIGN.md` | UI/UX design system — colors, typography, component rules |
| `docs/plans/` | Implementation plans for each task batch |
| `docs/adr/` | Architecture Decision Records |
| `docs/archive/` | Completed reference docs |

## Project Structure

```
lib/
├── core/           # Theme, router, errors, constants, utils
├── features/       # Feature modules (auth, profile, jobs, ...)
│   └── {feature}/
│       ├── data/           # Datasources, models, repository impl
│       ├── domain/         # Entities, abstract repos, use cases
│       └── presentation/   # Pages, widgets, providers
└── shared/         # Cross-feature entities, widgets, providers
```
