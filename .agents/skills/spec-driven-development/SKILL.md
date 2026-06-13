---
name: spec-driven-development
description: Mandates the creation of specifications before implementation. Use when starting new features, large changes, or when requirements are ambiguous.
---

# Spec-Driven Development

## Overview
Thinking before building prevents rework and ensures long-term alignment. This skill codifies a "Spec-First" mandate where a specification acts as a "source of truth" to guide all planning, implementation, and testing.

## When to Use
- Starting a non-trivial new feature or architectural change
- When user requirements are ambiguous or complex
- Proposing changes that touch multiple systems or libraries
- Documenting project decisions and technical designs

## Instructions
- **Mandate a Spec**: If the task is non-trivial and no spec exists, create one first. Don't start building until the spec is approved.
- **Draft the Spec**: Include the following components:
  - **Goal**: What are we building and why?
  - **Requirements**: Functional and non-functional constraints.
  - **Proposed Implementation**: Tech stack, architecture, and file changes.
  - **Verification Plan**: How will we prove it works? (Tests, manual checks).
- **Propose, Don't Assume**: If requirements are missing, surface them to the user as options instead of making arbitrary decisions.

## Spec Template
```markdown
# Spec: [Feature Name]

## 1. Goal
[Statement of intent]

## 2. Requirements
- [req1]
- [req2]

## 3. Implementation Plan
- [file1.ts]: Add X
- [file2.ts]: Update Y

## 4. Verification
- Run `npm test`
- Verify UI interaction in browser
```

## Best Practices
- **Atomic Specs**: Keep specs focused on a single feature or logical change.
- **Living Document**: Update the spec if significant implementation details change.
- **Source of Context**: Use the spec as high-priority context for subsequent coding tasks.

## Anti-Patterns
- **Building without a Spec**: Jumping into code for complex tasks "because it's obvious."
- **Spec Obsolescence**: Implementing something completely different from the spec without updating it.
- **Vague Requirements**: Using words like "better" or "faster" without measurable metrics.

## Related Resources
- **Related Skills**: `planning-and-task-breakdown`, `context-engineering`
