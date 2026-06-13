---
name: code-review-and-quality
description: Conducts multi-axis code reviews to ensure correctness, readability, architecture, security, and performance. Use before merging changes or when assessing code quality.
---

# Code Review and Quality

## Overview
Multi-axis code review ensures that every change meets the project's quality standards. This skill provides a structured framework for reviewing code with objective engineering principles.

## When to Use
- Before merging a Pull Request or a significant code change
- Assessing the quality of existing legacy code
- Verifying that a bug fix addresses the root cause
- Ensuring new features follow project architectural patterns

## Review Axes
- **Correctness**: Does the code fulfill requirements and handle edge cases?
- **Readability**: Is the logic clear and follows naming conventions?
- **Architecture**: Does it fit the system design and existing patterns?
- **Security**: Are there vulnerabilities or secrets in the code?
- **Performance**: Are there bottlenecks or inefficient patterns (e.g., N+1 queries)?

## Instructions
- **Review the Verification**: Check what tests were run and if the build passed. Require a "verification story" for every change.
- **Categorize Findings**: Use severity labels for clarity:
  - **Critical**: Blocks merge (security, data loss, broken functionality).
  - **Required**: Must address before merge.
  - **Nit**: Minor/optional style preference.
  - **Optional/Consider**: Suggestions for improvement.
- **Dead Code Hygiene**: Identify and remove unreachable or orphaned code. Ask before deleting if unsure.
- **Dependency Discipline**: Avoid adding new dependencies if the existing stack can solve the problem. Every dependency is a liability.

## Best Practices
- **Descriptive Tests**: Ensure tests have clear names and catch regressions.
- **Multi-Model Review**: Utilize different models for specialized review perspectives (e.g., security vs. architecture).
- **Fast Turnaround**: Prioritize review speed to avoid blocking the team.

## Anti-Patterns
- **Rubber-Stamping**: Avoid "LGTM" without evidence of a thorough review.
- **Softening Issues**: Don't downplay critical bugs; be direct about technical problems.
- **Deferred Cleanup**: Never accept "I'll fix it later." Require quality at the gate.

## Related Resources
- **Related Skills**: `security-and-hardening`, `performance-optimization`
