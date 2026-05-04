---
name: feature
description: Use when the user wants to implement a feature end-to-end in the JobConnect Flutter app. Handles the full implementation cycle — datasource, model, repository, use case, provider, and page — following Clean Architecture and all CLAUDE.md rules. Use this after scaffolding or for adding logic to existing feature skeletons. For UI design quality, combine with /impeccable craft.
---

Implement a feature end-to-end following JobConnect's Clean Architecture.

## Rules

1. **Follow CLAUDE.md strictly** — architecture, naming, patterns, forbidden patterns.
2. **Follow BRIEF.md** — feature spec, database schema, tech stack.
3. **Build bottom-up:** datasource → model → repository → use case → provider → page.
4. **Never skip layers.** Even simple features need all layers.
5. **Never add unapproved packages.** Check CLAUDE.md §Approved Packages.
6. **Ask before implementing** if the feature isn't in BRIEF.md §3 or TASKS.md.

## Setup

Before implementing:

1. **Read CLAUDE.md** — all rules.
2. **Read BRIEF.md** — feature requirements (§3), database schema (§7), constraints (§10).
3. **Check TASKS.md** — verify the feature is listed and not already done.
4. **Scan existing code** — check `lib/features/`, `lib/core/`, `lib/shared/` for reusable components.
5. **Check if scaffolded** — if `lib/features/{name}/` exists, build on it. Otherwise, scaffold first.

## Workflow

### Step 1 — Plan

Before writing any code, present a brief implementation plan:

```
## 🛠 Feature: {FeatureName}

### Tables Used
- {table1}: {purpose}
- {table2}: {purpose}

### Files to Create/Modify
1. datasource — {what it does}
2. model — {fields, from/toJson}
3. entity — {pure dart fields}
4. repository abstract — {methods}
5. repository impl — {maps datasource → domain}
6. use case — {business logic}
7. provider — {state management approach}
8. page — {UI layout description}
9. widgets — {reusable components}

### Dependencies
- Existing: {what we reuse}
- New: {what we create}
```

Wait for user confirmation.

### Step 2 — Data Layer

```
Order: datasource → model → repository_impl
```

**Datasource:**
- All Supabase calls here and ONLY here
- Catch exceptions → map to `Failure`
- Return raw data or model objects

**Model:**
- `@freezed` class with `fromJson` / `toJson`
- Maps 1:1 to database table columns
- Include `toEntity()` method

**Repository Impl:**
- Implements domain abstract repository
- Calls datasource methods
- Returns `Either<Failure, T>`

### Step 3 — Domain Layer

```
Order: entity → repository (abstract) → use case
```

**Entity:**
- Pure Dart class, NO Flutter/Supabase imports
- Business-relevant fields only

**Repository Abstract:**
- Interface with `Either<Failure, T>` return types
- One method per operation

**Use Case:**
- Single responsibility — one use case, one action
- Calls repository method
- Contains business rules (validation, transformation)

### Step 4 — Presentation Layer

```
Order: provider → widgets → page
```

**Provider:**
- `@riverpod` annotation (code generation)
- `AsyncNotifierProvider` for data from API
- `NotifierProvider` for local state
- One provider file = one concept

**Widgets:**
- Reusable, focused components
- Use `AppColors`, `AppTextStyles` — no hardcoded values
- `const` constructors

**Page:**
- Composes widgets
- Uses `ref.watch()` for state
- `AsyncValue.when()` for loading/error/data
- Navigation via go_router

### Step 5 — Integration

- Add route to `core/router/`
- Register provider if needed
- Run `dart run build_runner build` for code generation

### Step 6 — Verify

After implementation, self-review against:
- [ ] No architecture boundary violations
- [ ] No forbidden patterns
- [ ] All naming conventions followed
- [ ] Error handling with `Either<Failure, T>`
- [ ] `const` and `final` used properly
- [ ] No hardcoded colors/strings/keys

## Output

After completing each layer, show a summary:

```
## ✅ Implemented: {FeatureName}

### Files Created
- `lib/features/{name}/data/datasources/{name}_datasource.dart`
- ... (full list)

### Integration Steps
- [ ] Add route to router
- [ ] Run `dart run build_runner build`
- [ ] Test on device

### Related Skills
- `/review features/{name}/` — review the implementation
- `/impeccable craft {Page}` — polish the UI
- Update TASKS.md checkbox
```
