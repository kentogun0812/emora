---
name: context-engineering
description: Optimizes agent context for better task performance. Use when starting new sessions, task quality degrades, or when organizing project rules and documentation.
---

# Context Engineering

## Overview
Context is the primary determinant of agent performance. This skill focuses on the strategic organization and management of information in the context window to prevent hallucinations and ensure adherence to conventions.

## When to Use
- Starting a fresh agent session or a new major task
- When agent performance or quality begins to degrade
- Organizing project documentation and standard rules
- Handling large-scale refactors where context relevance is critical

## Instructions
- **Follow the Context Hierarchy**:
  1. **Rules Files**: Critical project-wide conventions.
  2. **Specs & Architecture**: Targeted sections of design docs.
  3. **Source Files**: Relevant code, tests, and type definitions.
  4. **Error Output**: Specific failure logs (not full outputs).
- **Control Context Flow**:
  - Start fresh sessions when switching major domains.
  - Summarize progress periodically in long conversations.
  - Compact or clear stale context to maintain focus.
- **Manage Confusion**:
  - Never guess when context is ambiguous or conflicting.
  - Surface disagreements (e.g., Code vs. Spec) to the user.
  - Ask for missing requirements instead of inventing them.

## Best Practices
- **Selective Inclusion**: Aim for <2,000 lines of highly relevant code per task.
- **Inline Planning**: Emit a lightweight plan before executing multi-step operations.
- **Verification**: Ensure the agent output actually follows the provided rules and patterns.

## Anti-Patterns
- **Context Starvation**: Running tasks without enough project-specific rules or source context.
- **Context Flooding**: Loading thousands of lines of irrelevant documentation, which degrades attention.
- **Stale Context**: Referencing outdated patterns from long-running sessions.
- **Silent Confusion**: Guessing on ambiguous requirements instead of asking for clarification.

## Related Resources
- **Related Skills**: `planning-and-task-breakdown`, `spec-driven-development`
