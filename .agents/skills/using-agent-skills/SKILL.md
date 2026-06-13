---
name: using-agent-skills
description: Discovers and invokes appropriate agent skills for a given task. Always use this to find the correct process-oriented guidance at the start of a session.
---

# Using Agent Skills

## Overview
Skills provide structured, process-oriented guidance that prevents common mistakes and ensures production-quality output. They are the "operational manual" for advanced coding tasks, encoding best practices from building and scaling high-quality systems.

## When to Use
- At the start of a new agent session to establish workflows
- When moving between different phases of development (e.g., from Build to Verify)
- When tasks feel complex or have high error risk
- Reviewing work to ensure compliance with project standards

## Instructions
- **Check for Skills First**: At the start of every task, identify which skills apply. Trigger them explicitly to load their instructions.
- **Follow the Lifecycle**:
  - **Define**: `spec-driven-development`, `context-engineering`.
  - **Plan**: `planning-and-task-breakdown`.
  - **Build**: `incremental-implementation`, `test-driven-development`.
  - **Verify**: `browser-testing-with-devtools`, `debugging-and-error-recovery`.
  - **Review**: `code-review-and-quality`, `security-and-hardening`.
- **Enforce Precision**: Follow skill instructions in order. A task is not complete until the skill's verification steps pass.
- **Surface Inconsistencies**: If a task deviates from a skill's best practices, flag it to the user.

## Best Practices
- **Atomic Application**: Don't load every skill at once; only those relevant to the current phase of work.
- **Combine Skills**: Use skills in sequence (e.g., Plan -> Build -> Verify).
- **Verify Evidence**: Ensure completion is backed by evidence (passing builds, screenshots, logs).

## Anti-Patterns
- **Skipping Skills**: Plowing ahead without process guidance because the task "feels easy."
- **Check-the-Box Mentality**: Claiming a skill was used without actually following its core instructions.
- **Process Over Outcome**: Following skill steps blindly when they don't apply to a unique edge case; the goal is still quality code.

## Related Resources
- **Skill Search**: Use `list_dir` on `.agents/skills/` to discover available capabilities.
