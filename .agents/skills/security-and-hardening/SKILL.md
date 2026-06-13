---
name: security-and-hardening
description: Hardens applications against vulnerabilities and misconfigurations. Use when handling user input, authentication, sensitive data, or external integrations.
---

# Security and Hardening

## Overview
Security is not a final step but a continuous process. This skill focuses on proactive hardening and the implementation of defensive patterns across the full application stack.

## When to Use
- Implementing authentication or authorization logic
- Handling user-submitted data or file uploads
- Configuring external API integrations or database connections
- Reviewing code for potential vulnerabilities (OWASP Top 10)

## Instructions
- **Validate at Boundaries**: Never trust external data. Validate all user input, API responses, and file uploads at the system boundary using schemas (e.g., Zod).
- **Enforce Access Control**: Every protected resource must check for both authentication (who are you?) and authorization (what can you do?).
- **Sanitize Output**: Prevent injection attacks (XSS, SQLi) by using framework auto-escaping and parameterized queries.
- **Manage Secrets**: Never commit secrets or PII to version control. Use environment variables and secret managers.
- **Audit Dependencies**: Regularly run `npm audit` and triage findings based on reachability and severity.

## Security Review Decision Tree (`npm audit`)
- **High/Critical Severity**:
  - Reachable in production? -> **Fix Immediately**.
  - Dev-only or unreachable? -> **Fix soon**.
- **Moderate/Low Severity**:
  - Reachable? -> **Fix next release**.
  - Dev-only? -> **Fix when convenient**.

## Best Practices
- **Security Headers**: Use `helmet` or similar to set CSP, HSTS, and other protective headers.
- **Rate Limiting**: Apply strictly to authentication and sensitive endpoints.
- **Least Privilege**: Grant only the minimum permissions required for a service or user to function.

## Anti-Patterns
- **Trusting the Frontend**: Never rely on frontend validation for security; performance only.
- **Secrets in Git**: Committing `.env` files or hardcoded keys.
- **Verbose Errors**: Exposing stack traces or internal DB schemas to the end user.
- **Security by Obscurity**: Assuming a hidden URL or non-obvious parameter is safe.

## Related Resources
- **Related Skills**: `code-review-and-quality`, `context-engineering`
