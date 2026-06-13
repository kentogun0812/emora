---
name: debugging-and-error-recovery
description: Provides a systematic approach to root-cause debugging and error recovery. Use when tests fail, builds break, or application behavior deviates from expectations.
---

# Debugging and Error Recovery

## Overview
Systematic debugging moves from symptoms to root causes. This skill provides a structured method forReproducing, triaging, and fixing application issues while preventing regressions.

## When to Use
- When tests fail or builds break
- Application behavior deviates from the expected specification
- Investigating performance regressions or logic flaws
- Recovering from critical system errors or failures

## Instructions
- **Reproduction**: Create a minimal reproduction case. A bug you can't reliably reproduce is a bug you can't reliably fix.
- **Triage and Isolate**:
  - **Environment**: Is it a local, CI, or production-specific issue?
  - **Scope**: Is it a frontend, backend, or database problem?
  - **Timeline**: When did it start? What changed recently?
- **Root Cause Analysis**:
  - Check logs, stack traces, and network requests.
  - Formulate a hypothesis and test it (e.g., "If I mock this service, does the error persist?").
  - Use the "5 Whys" to reach the architectural root cause.
- **Implement and Verify**:
  - Apply the fix and verify against the reproduction case.
  - Add a regression test to prevent the bug from returning.
  - Verify that the fix doesn't introduce side effects.

## Best Practices
- **Divide and Conquer**: Comment out code or use binary search (Bisect) to isolate the failing component.
- **Log Review**: Read logs from the beginning of the failure, not just the last line.
- **Tooling**: Use debuggers, browser DevTools, and performance profilers to see state.

## Anti-Patterns
- **Guess-Fixing**: Applying multiple random changes hoping one works.
- **Fixing Symptoms**: Patching the error message without addressing the underlying logic flaw.
- **Ignoring Flaky Tests**: Treating intermittent failures as "glitches" rather than underlying race conditions or state leaks.

## Related Resources
- **Related Skills**: `browser-testing-with-devtools`, `code-review-and-quality`
