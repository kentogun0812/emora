---
name: vercel-react-view-transitions
description: Implements smooth animations using React's View Transition API. Use for page transitions, shared element morphs, or animating list reorders without third-party libraries.
---

# React View Transitions

## Overview
Modern, native-feeling transitions using the browser's View Transition API. This skill covers directional navigation, shared element morphs, and list animations to create fluid, cinematic application interfaces.

## When to Use
- Implementing page transitions between App Router routes
- Creating shared element morphs (e.g., image thumbnail to detail)
- Animating list reorders or enter/exit states
- Building sophisticated UI motions without external animation libraries

## Instructions
- **Use the `<ViewTransition>` Component**: Wrap components that need enter/exit or shared element animations.
- **Implement Directional Transitions**: 
  - Use `enter` and `exit` props with transition types (e.g., `nav-forward`, `nav-back`).
  - Always provide a `default` key when using type-keyed transition maps.
- **Shared Element Morphs**: 
  - Use matching `name` props on VTs in different views for morphing shared elements.
  - Ensure `name` is unique (`item-image-${id}`) if multiple instances exist.
- **Performance Optimization**: 
  - Set `default="none"` on VTs to prevent global cross-fades during non-navigation updates (e.g., Suspense reveals).
  - Use `router.push()` with explicit types instead of `router.back()` for reliable transitions.

## Best Practices
- **Pair Enter with Exit**: Always define both sides of an animation for a cohesive experience.
- **Reduced Motion**: Include the standard reduced motion CSS to respect user preferences.
- **List Identity**: Wrap list items in a `<ViewTransition>` based on their `key` to animate reorders.

## Anti-Patterns
- **Duplicate Names**: Multiple mounted VTs with the same `name` will break the transition.
- **Synchronous Nav**: Using `router.back()` or the browser back button (which are synchronous) for complex View Transitions.
- **Over-Animating**: Forgetting `default="none"`, causing every re-render to trigger a global cross-fade.

## Related Resources
- **Related Skills**: `vercel-react-best-practices`, `web-design-guidelines`
