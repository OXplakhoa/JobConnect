---
name: scaffold
description: Use when the user wants to create the folder structure and boilerplate files for a new feature in the JobConnect Flutter app. Generates Clean Architecture scaffolding (data/domain/presentation layers) with proper naming conventions, empty but correctly-typed files, and Riverpod provider stubs. Does NOT implement business logic — only creates the skeleton.
---

Scaffold a new feature's folder structure following JobConnect's Clean Architecture.

## Rules

1. **Follow CLAUDE.md naming conventions exactly.** No exceptions.
2. **Follow the folder structure defined in BRIEF.md §6.**
3. **Generate minimal boilerplate** — correct types, imports, and signatures, but NO business logic.
4. **Never add packages** not in the approved list (CLAUDE.md §Approved Packages).
5. **Ask for confirmation** before creating files. Show the tree first.

## Setup

Before scaffolding:

1. **Read CLAUDE.md** — architecture rules, naming, folder conventions.
2. **Read BRIEF.md** — check if the feature exists in §3, get relevant DB tables from §7.
3. **Check existing features** — scan `lib/features/` to follow established patterns.

## Workflow

### Step 1 — Identify Feature

Parse the user's request to determine:
- Feature name (snake_case for folders)
- Which database tables are involved (from BRIEF.md §7)
- Which entities/models are needed

### Step 2 — Show Plan

Display the proposed tree BEFORE creating anything:

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   │   └── {feature}_datasource.dart
│   ├── models/
│   │   └── {feature}_model.dart
│   └── repositories/
│       └── {feature}_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── {entity}.dart
│   ├── repositories/
│   │   └── {feature}_repository.dart
│   └── usecases/
│       └── get_{feature}_usecase.dart
└── presentation/
    ├── pages/
    │   └── {feature}_page.dart
    ├── providers/
    │   └── {feature}_provider.dart
    └── widgets/
        └── {feature}_card.dart
```

Ask user to confirm or adjust.

### Step 3 — Generate Files

Each file contains:
- Correct imports
- Class declaration with proper naming (`XxxRepository`, `XxxRepositoryImpl`, etc.)
- Method signatures matching the feature's needs (from DB schema)
- `@riverpod` annotations for providers
- `@freezed` annotations for models
- `Either<Failure, T>` return types for repositories
- **NO implementation bodies** — just `throw UnimplementedError();` or `TODO` markers

### Step 4 — Checklist

After scaffolding, output:

```
## ✅ Scaffolded: {FeatureName}

Files created:
- [ ] datasource — {path}
- [ ] model — {path}
- [ ] repository (abstract) — {path}
- [ ] repository (impl) — {path}
- [ ] entity — {path}
- [ ] usecase — {path}
- [ ] provider — {path}
- [ ] page — {path}
- [ ] widget — {path}

Next steps:
- `/feature {name}` to implement business logic
- `/impeccable craft {Page}` to design the UI
- Add route to `core/router/`
```

## File Templates

### Entity (domain/entities/)
```dart
// Pure Dart — no Flutter, no Supabase, no Riverpod
class {Entity} {
  final String id;
  // ... fields from BRIEF.md schema
  const {Entity}({required this.id, ...});
}
```

### Repository Abstract (domain/repositories/)
```dart
import 'package:dartz/dartz.dart';
abstract class {Feature}Repository {
  Future<Either<Failure, List<{Entity}>>> getAll();
  Future<Either<Failure, {Entity}>> getById(String id);
}
```

### Provider (presentation/providers/)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '{feature}_provider.g.dart';

@riverpod
class {Feature}Notifier extends _${Feature}Notifier {
  @override
  Future<List<{Entity}>> build() async {
    throw UnimplementedError();
  }
}
```
