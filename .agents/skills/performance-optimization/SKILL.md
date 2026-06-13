---
name: performance-optimization
description: Optimizes application performance across the stack. Use when performance requirements exist, load times are slow, or Core Web Vitals need improvement.
---

# Performance Optimization

## Overview
Performance is a feature. This skill focuses on measurable improvements to load time, responsiveness, and resource efficiency through a cycle of measurement and optimization.

## When to Use
- When page load times exceed project targets
- Improving Core Web Vitals (LCP, CLS, INP)
- Optimizing slow database queries or API response times
- Reducing client-side re-renders or bundle size

## Instructions
- **Baseline and Measure**: Always record baseline metrics before optimizing.
  - **Frontend**: LCP (Largest Contentful Paint), CLS (Cumulative Layout Shift), INP (Interaction to Next Paint).
  - **Backend**: API response time, Database query duration, Memory usage.
- **Identify Bottlenecks**:
  - Use Chrome DevTools for frontend profiling.
  - Use database EXPLAIN plans for slow queries.
  - Profile CPU and memory for backend services.
- **Implement Optimizations**:
  - **Caching**: Use Redis, browser cache, or CDN edge caching.
  - **Code Splitting**: Lazy load components and assets.
  - **Efficiency**: Eliminate N+1 queries and unnecessary re-renders.
  - **Compression**: Minimize payloads and use modern image formats (WebP/AVIF).
- **Verify Improvement**: Rerun measurements and compare against the baseline.

## Best Practices
- **The 80/20 Rule**: Focus on the 20% of code that accounts for 80% of execution time.
- **Lazy Load by Default**: Don't send bytes to the user until they are needed.
- **Pagination**: Never return unbounded lists in API responses.

## Anti-Patterns
- **Premature Optimization**: Optimizing code that isn't a bottleneck, increasing complexity for no gain.
- **Guessing Performance**: Assuming a change is faster without measuring.
- **Micro-Optimizations**: Focusing on small syntax changes while ignoring large architectural inefficiencies (e.g., synchronous I/O).

## Related Resources
- **Related Skills**: `browser-testing-with-devtools`, `web-design-guidelines`
