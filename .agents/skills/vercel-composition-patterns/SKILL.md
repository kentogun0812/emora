---
name: vercel-composition-patterns
description: React composition patterns for building flexible, maintainable components. Use when refactoring components with prop proliferation or designing reusable APIs.
---

# React Composition Patterns

## Overview
Build components that scale by using composition instead of configuration. This skill focuses on avoiding boolean prop proliferation by leveraging compound components and React context to create flexible, maintainable component APIs.

## When to Use
- Refactoring components with many boolean or configuration props
- Building reusable component libraries or design systems
- Designing flexible APIs where internal logic needs to be decoupled from UI
- Implementing complex UI components like Tabs, Modals, or Forms

## Instructions
- **Avoid Boolean Props**: Don't add boolean props (e.g., `showIcon`, `isSmall`) to customize behavior. Instead, use composition (e.g., `<Button><Icon /> Text</Button>`).
- **Use Compound Components**: Structure complex components (e.g., Tabs, Modals) using shared context to manage internal state while keeping the API flexible.
- **Lift State to Providers**: Move state into internal context providers to allow decoupled sibling components to share logic without prop drilling.
- **Implement Explicit Variants**: Create dedicated variant components rather than using a single "god component" with multiple modes.

## Priority Categories
1. **Architecture**: Focus on composition over configuration (High Impact).
2. **State Management**: Decouple state management from internal UI (Medium Impact).
3. **React 19 APIs**: Use `use()` and prop-based `ref` instead of `forwardRef` (where applicable).

## Best Practices
- **Generic Interfaces**: Define generic interfaces for context providers to enable dependency injection.
- **Children over Render Props**: Prefer using `children` for simple composition; use render props only for complex layout/logic sharing.
- **Clean API**: Aim for a "Boring" API that doesn't surprise the user with hidden side effects.

## Anti-Patterns
- **Prop Drills**: Passing data through multiple layers of components that don't need it.
- **Configuration Overload**: Creating components with dozens of optional props that attempt to cover every use case.
- **State Leaks**: Exposing internal component state to its parents unnecessarily.

## Related Resources
- **Related Skills**: `vercel-react-best-practices`, `web-design-guidelines`
