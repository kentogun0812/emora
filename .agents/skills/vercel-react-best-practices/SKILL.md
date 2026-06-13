---
name: vercel-react-best-practices
description: React and Next.js performance optimization guidelines from Vercel Engineering. Use when writing, reviewing, or refactoring React/Next.js code for optimal performance.
---

# React Best Practices (Vercel)

## Overview
Ensure optimal performance and maintainability in React and Next.js applications by following Vercel's engineering standards. This skill focuses on minimizing re-renders, optimizing bundles, and leveraging modern React APIs efficiently.

## When to Use
- Writing or refactoring core React components
- Optimizing Next.js application performance and data fetching
- Reviewing code for inefficient patterns or performance bottlenecks
- Implementing complex UI logic where smoothness is critical

## Rule Categories by Priority
1. **Async & Fetching**: Optimize data loading and parallel execution (Critical).
2. **Bundle Optimization**: Minimize bundle size and avoid barrel imports (High).
3. **Component Cleanup**: Prevent memory leaks and excessive re-renders (Medium).
4. **Rendering Performance**: Use efficient patterns for SVG, lists, and hydration (Medium).
5. **JS Efficiency**: Optimize loops, lookups, and state subscriptions (Low).

## Instructions
- **Parallelize Async Tasks**: Use `Promise.all` for independent awaits.
- **Avoid Content Shift**: Prefer `useTransition` for non-urgent updates and loading states.
- **Simplify Conditionals**: Use ternary operators instead of `&&` to avoid rendering `0` or `false` in the DOM.
- **Optimize Re-renders**:
  - Extract expensive logic into memoized components.
  - Derive state during render instead of inside `useEffect`.
  - Use functional `setState` for stable callbacks.
- **Hydration Hygiene**: Avoid flickering by using inline scripts for client-only data and suppress expected mismatches only where strictly necessary.

## Best Practices
- **Explicit Literals**: Define static objects and arrays outside components to prevent reference inequality.
- **O(1) Lookups**: Use `Set` or `Map` for frequent presence checks or lookups in loops.
- **Barrel Import Avoidance**: Import directly from submodules to reduce bundle impact.

## Anti-Patterns
- **Inline Components**: Never define a React component inside another component.
- **Effect-Driven Derivation**: Updating state inside an effect when it could be computed during render.
- **Heavy Transitions**: Blocking the main thread with expensive synchronous work.

## Related Resources
- **Related Skills**: `vercel-composition-patterns`, `performance-optimization`
