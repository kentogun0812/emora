---
name: web-design-guidelines
description: Review UI code for Web Interface Guidelines compliance. Use when asked to audit design, check accessibility, or review UX against best practices.
---

# Web Interface Guidelines

## Overview
Audits UI implementations for compliance with established Web Interface Guidelines. This skill ensures that designs are accessible, consistent, and adhere to modern UX best practices by fetching and applying the latest rules from a central source.

## When to Use
- When asked to "review my UI" or "audit my design"
- Checking for accessibility compliance (contrast, labels, hierarchy)
- Verifying that new screens match project design standards
- Finalizing UI before a production shipping gate

## Instructions
- **Fetch the Latest Guidelines**: Before every review, fetch the fresh rules from:
  `https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md`
- **Audit specified files**:
  - Read target files or patterns provided by the user.
  - Apply the rules from the fetched guidelines.
  - Output findings in the terse `file:line` format.
- **Reporting findings**:
  - Categorize by severity (e.g., Contrast fix, Accessibility issue).
  - Provide actionable suggestions for each violation.

## Best Practices
- **Context Integration**: Cross-reference findings with `browser-testing-with-devtools` for live verification.
- **Continuous Review**: Run this skill during the `code-review-and-quality` phase for all UI-related changes.

## Anti-Patterns
- **Static Rule Application**: Using outdated internal rules instead of fetching the latest guidelines.
- **Silent Violations**: Notifying but not explaining why a design choice violates a guideline.

## Related Resources
- **Related Skills**: `browser-testing-with-devtools`, `code-review-and-quality`
