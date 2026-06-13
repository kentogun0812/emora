---
name: planning-and-task-breakdown
description: Breaks complex goals into actionable, ordered tasks. Use when starting new features, large refactors, or when a task feels too large to begin.
---

# Planning and Task Breakdown

## Overview
Structured planning prevents scope creep and ensures a logical implementation path. This skill focuses on decomposing fuzzy goals into atomic, verifiable tasks to reduce cognitive load and improve velocity.

## When to Use
- Starting a new feature or sub-system
- Executing large-scale refactors
- When a task feels too large or ambiguous to begin directly
- Proposing an implementation path for user approval

## Instructions
- **Capture Intent**: Fully understand the requirement and constraints before planning.
- **Analyze Dependencies**: Identify what must be built first (e.g., Database schema -> API -> Frontend UI).
- **Create Atomic Tasks**:
  - Each task should be independent and verifiable.
  - Tasks should be small enough to complete in a single work session.
  - Use clear, action-oriented titles (e.g., "Add Zod validation to Task schema").
- **Order for Success**: Sequence tasks to minimize rework and provide early value/feedback.
- **Surface Ambiguity**: If a requirement is unclear, add a "Clarification" task at the start.

## Best Practices
- **The Done Definition**: Define success criteria for every task.
- **Risk Assessment**: Identify high-risk tasks (unfamiliar tech, complex logic) and tackle them early.
- **Iterative Refinement**: Update the plan as you learn more during implementation.

## Anti-Patterns
- **Elephant Tasks**: Creating giant, multi-day tasks that lead to long branches and merge conflicts.
- **Linear Blindness**: Planning without considering parallel work opportunities or critical path dependencies.
- **Over-Planning**: Attempting to plan every detail of a 6-month project upfront; keep granularity high for the immediate future.

## Related Resources
- **Related Skills**: `spec-driven-development`, `context-engineering`
