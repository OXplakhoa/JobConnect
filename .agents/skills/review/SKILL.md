---
name: review
description: Use when the user wants to review code for compliance with project rules, find bugs, check architecture violations, or ensure code quality before committing. Reviews against CLAUDE.md rules, Clean Architecture boundaries, Riverpod patterns, naming conventions, forbidden patterns, and Supabase best practices. Outputs findings but does NOT auto-fix — suggests fixes for the user to approve.
---

Review code against JobConnect project rules. Find violations, suggest fixes, never auto-apply.

## Rules

1. **Review against CLAUDE.md** as the source of truth for all conventions.
2. **Never auto-fix code.** Report findings and suggest fixes. User decides.
3. **Prioritize findings** by severity: 🔴 Critical → 🟡 Warning → 🔵 Info.
4. **Check all layers** — don't just lint syntax, verify architecture boundaries.

## Setup

Before reviewing:

1. **Read CLAUDE.md** — all rules sections.
2. **Read the target file(s)** — the code to review.
3. **Read related files** if needed — to check cross-layer violations.

## Checklist

Run every check on the target file(s). Skip checks that don't apply.

### 1. Architecture Boundaries
- [ ] Widget/Provider does NOT call Supabase directly
- [ ] Data layer does NOT import Flutter widgets
- [ ] Domain layer does NOT import Supabase or Riverpod
- [ ] Business logic is NOT inside Widget `onPressed` / `build()`

### 2. Riverpod Patterns
- [ ] Uses `@riverpod` annotation, NOT manual `Provider()` constructors
- [ ] Uses `AsyncNotifierProvider` for async data
- [ ] Uses `NotifierProvider` for sync state
- [ ] No `ref.read()` inside `build()` — only `ref.watch()`
- [ ] One provider per file, one concept per provider

### 3. Naming Conventions
- [ ] File names: `snake_case.dart`
- [ ] Classes: `PascalCase`
- [ ] Variables/functions: `camelCase`
- [ ] Constants: `kCamelCase`
- [ ] Private: `_camelCase`
- [ ] Pages: `XxxPage`
- [ ] Widgets: `XxxWidget` / `XxxCard`
- [ ] Providers: `xxxProvider`
- [ ] Repositories: `XxxRepository` (abstract) / `XxxRepositoryImpl`
- [ ] Datasources: `XxxDatasource`
- [ ] Use cases: `XxxUseCase`
- [ ] Models: `XxxModel`
- [ ] Entities: `Xxx` (no suffix)

### 4. Forbidden Patterns (CLAUDE.md §Forbidden)
- [ ] No `setState()` — must use Riverpod
- [ ] No `Navigator.push()` — must use go_router
- [ ] No `Supabase.instance.client` outside `datasources/`
- [ ] No hardcoded colors — must use `AppColors.xxx`
- [ ] No hardcoded strings — must use constants
- [ ] No `print()` — must use `debugPrint()` or Logger
- [ ] No API keys in code — must use `--dart-define`
- [ ] No `dynamic` type

### 5. Error Handling
- [ ] Repositories return `Either<Failure, T>` — no thrown exceptions
- [ ] Datasources catch exceptions and map to `Failure`
- [ ] Providers use `AsyncValue.when()` for loading/error/data
- [ ] Specific `Failure` subclasses, not generic strings

### 6. Dart Style
- [ ] `const` constructors where possible
- [ ] `final` preferred over `var`
- [ ] Dart 3.x features used where appropriate (sealed, switch expr, records)

### 7. Supabase Rules
- [ ] Current user via `Supabase.instance.client.auth.currentUser`
- [ ] Realtime subscriptions use `ref.onDispose` for cleanup
- [ ] Storage paths follow convention: `resumes/{userId}/`, `avatars/{userId}/`
- [ ] RLS assumed ON — no queries that bypass it

### 8. AI Feature Rules (if applicable)
- [ ] Gemini calls only in `AiSuggestionDatasource`
- [ ] Results cached in `ai_suggestions`, TTL = 24h
- [ ] Rate limit: 1 req/user/5min at repository level
- [ ] Prompt templates in `core/constants/prompt_templates.dart`

## Output Format

```
## 🔍 Code Review: {file_path}

### Summary
{1-2 sentence overview}

### Findings

#### 🔴 Critical
1. **[Category]** Line {N}: {description}
   - **Rule:** {CLAUDE.md reference}
   - **Fix:** {suggested fix}

#### 🟡 Warning
1. **[Category]** Line {N}: {description}
   - **Rule:** {CLAUDE.md reference}
   - **Fix:** {suggested fix}

#### 🔵 Info
1. **[Category]** Line {N}: {description}
   - **Suggestion:** {improvement}

### Score: {X}/10

### Next Steps
- `/feature {name}` to implement fixes
- `/impeccable polish {target}` for UI refinements
```

## Multi-file Review

When reviewing a full feature (`/review features/jobs/`):
1. Review each file individually
2. Also check cross-file relationships (imports, dependencies)
3. Summarize the feature-level findings at the end
