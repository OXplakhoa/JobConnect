---
name: ask
description: Use when the user wants to ask questions about the codebase, features, architecture, database schema, Flutter patterns, Supabase integration, or any technical aspect of the JobConnect project. This skill NEVER writes, edits, or generates code files. It only reads, analyzes, and explains. Use for understanding existing code, planning decisions, comparing approaches, debugging concepts, or learning how a feature works.
---

Answer questions about the JobConnect codebase. Read-only — never edit project files.

## Rules

1. **NEVER create, edit, or delete any project file.** This is a read-only skill.
2. **NEVER generate implementation code** in your response. Short illustrative snippets (≤15 lines) to explain a concept are OK, but they must be clearly labeled as examples, not implementations.
3. **Always ground answers in the actual codebase.** Read relevant files before answering. Don't guess file contents.
4. **Reference BRIEF.md and CLAUDE.md** when the question touches architecture, conventions, or feature scope.
5. If the question leads to an action, suggest the appropriate skill (`/scaffold`, `/feature`, `/review`, `/supa`, `/impeccable`) instead of doing the work.

## Setup

Before answering, gather context:

1. **Read CLAUDE.md** — coding rules, architecture, naming conventions, forbidden patterns.
2. **Read BRIEF.md** — feature list, tech stack, database schema, constraints.
3. **Scan relevant source files** — use grep/view to find the code related to the question.

## Question Categories

### Architecture & Patterns
- How does Clean Architecture work in this project?
- How should Riverpod providers be structured?
- What's the data flow for feature X?

→ Reference: `CLAUDE.md` §Architecture Rules, `BRIEF.md` §5 Kiến trúc

### Feature Understanding
- What does feature X do? How is it implemented?
- What tables does feature X use?
- What's the user flow for feature X?

→ Reference: `BRIEF.md` §3 Tính năng, §7 Database Schema

### Database & Supabase
- What's the schema for table X?
- How do RLS policies work for this feature?
- How does Realtime chat work?

→ Reference: `BRIEF.md` §7 Database Schema, `CLAUDE.md` §Supabase Rules

### AI Features
- How does vector search work?
- What's the embedding pipeline?
- How does Skill Gap Analysis work?

→ Reference: `BRIEF.md` §3.3 Stand-out Features, §4 AI — Vector Search

### Code Conventions
- What naming convention should I use for X?
- Is this package approved?
- What's the correct way to do X in this project?

→ Reference: `CLAUDE.md` §Code Style, §Naming Conventions, §Approved Packages

### Comparison & Decision
- Should I use approach A or B?
- What are the trade-offs of X?

→ Analyze both options against project rules, then recommend with reasoning.

## Response Format

```
## 📖 [Question restated concisely]

### Answer
[Clear, grounded explanation]

### References
- [Link to relevant files or sections]

### Next Steps (if applicable)
- Suggest which skill to use: `/scaffold`, `/feature`, `/review`, `/supa`, `/impeccable`
```

## Boundaries

| Allowed | Not Allowed |
|---|---|
| Read any project file | Create or edit files |
| Explain code patterns | Generate implementation code |
| Compare approaches | Make architectural decisions without user input |
| Reference documentation | Assume file contents without reading |
| Suggest next skill to use | Execute the next skill |
| Short example snippets (≤15 lines) | Full code blocks meant for copy-paste |
