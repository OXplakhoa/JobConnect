---
name: explain
description: Deep-dive explainer for any codebase — features, architecture, data flow, code logic, and design patterns. Produces comprehensive, friendly answers with Mermaid diagrams for visual clarity. Use when the user wants to understand how code works, trace a feature's flow, visualize architecture, compare design decisions, or learn why code is structured a certain way. Triggers on questions like "how does X work", "explain this code", "walk me through", "show me the flow", "what does this do", or "why is it built this way".
---

# Explain

Comprehensive, visual code explainer. Read-only — never edit project files.

## Rules

1. **NEVER create, edit, or delete any project file.** Read-only skill.
2. **Always read the actual code before answering.** Never guess or assume file contents.
3. **No vague answers.** Every claim must be grounded in specific files, line ranges, and function names.
4. **Be friendly and approachable.** Write like a patient senior dev explaining to a teammate.
5. **Use diagrams.** Include at least one Mermaid diagram when explaining flows, architecture, or relationships.
6. **Short code snippets are OK** (≤20 lines) to illustrate a point, but label them as excerpts.
7. If the question leads to an action (refactor, implement, fix), suggest the appropriate skill instead of doing the work.

## Workflow

### Step 1 — Orient

Before answering any question:

- [ ] Read project-level docs if they exist (`README.md`, `CLAUDE.md`, `BRIEF.md`, `CONTEXT.md`, `docs/`)
- [ ] Identify the language, framework, and architecture pattern
- [ ] Scan the directory structure to understand module boundaries

### Step 2 — Investigate

Based on the question:

- [ ] Use `grep_search` to find relevant symbols, functions, classes, or keywords
- [ ] Read the relevant source files with `view_file`
- [ ] Trace the call chain: entry point → business logic → data layer
- [ ] Note any patterns: DI, state management, error handling, caching

### Step 3 — Explain

Structure every answer using the response format below. Adapt depth to the question:

- **"What does X do?"** → Feature summary + key files + data flow diagram
- **"How does X work?"** → Step-by-step walkthrough + sequence diagram + code excerpts
- **"Why is X built this way?"** → Design rationale + trade-offs + alternatives
- **"Show me the architecture"** → Layer diagram + dependency graph + module map
- **"Compare A vs B"** → Side-by-side table + pros/cons + recommendation

## Diagrams

Always use Mermaid syntax in fenced code blocks. Pick the right diagram type:

| Question Type | Diagram Type | Mermaid Keyword |
|---|---|---|
| Data/request flow | Sequence diagram | `sequenceDiagram` |
| Architecture layers | Flowchart | `flowchart TD` |
| State transitions | State diagram | `stateDiagram-v2` |
| Class relationships | Class diagram | `classDiagram` |
| Process/pipeline | Flowchart | `flowchart LR` |
| Feature dependencies | Graph | `graph TD` |
| Decision logic | Flowchart | `flowchart TD` |

### Diagram guidelines

- Keep nodes ≤ 8 per diagram. Split into multiple diagrams if complex.
- Label edges with the action/data being passed.
- Quote labels containing special characters.
- Use subgraphs to group related nodes by layer or module.

## Response Format

Write responses as **artifacts** (markdown files) for anything beyond a quick answer.

```
## 🔍 [Question restated clearly]

### TL;DR
[2-3 sentence summary for the impatient]

### How It Works
[Detailed, step-by-step explanation with file references]

### Visual Flow
[Mermaid diagram(s)]

### Key Files
| File | Role |
|---|---|
| `path/to/file.dart` | Brief description |

### Code Excerpts (if helpful)
[Short, annotated snippets from the actual codebase]

### Gotchas & Edge Cases (if relevant)
[Things that might trip someone up]

### Related
- Links to related features, patterns, or docs
- Suggested skill if action is needed: `/feature`, `/scaffold`, `/review`, etc.
```

## Boundaries

| ✅ Allowed | ❌ Not Allowed |
|---|---|
| Read any file in the codebase | Create, edit, or delete files |
| Explain code patterns and decisions | Generate implementation code |
| Create Mermaid diagrams | Make changes without user consent |
| Compare approaches with trade-offs | Give vague "it depends" answers without specifics |
| Reference documentation and source | Assume file contents without reading |
| Suggest next skill to use | Execute the next skill |
| Short annotated excerpts (≤20 lines) | Full code blocks meant for copy-paste |
