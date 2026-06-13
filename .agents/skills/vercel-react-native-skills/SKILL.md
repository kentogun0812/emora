---
name: vercel-react-native-skills
description: React Native and Expo best practices for building performant mobile apps. Use when building RN components, optimizing lists, or implementing mobile-first UI patterns.
---

# React Native Skills

## Overview
Build performant, native-feeling mobile applications with React Native and Expo. This skill focuses on GPU-accelerated animations, efficient list virtualization, and leveraging native platform UI patterns for a premium mobile experience.

## When to Use
- Building or optimizing React Native/Expo mobile applications
- Implementing complex lists or scroll-intensive interfaces
- Creating high-performance animations with Reanimated
- Handling platform-specific UI patterns (Safe Area, Native Modals)

## Rule Categories by Priority
1. **List Performance**: `FlashList`, memoization, and item optimization (Critical).
2. **Animation**: GPU-accelerated transforms and Reanimated patterns (High).
3. **Navigation**: Native stack and tab navigators (High).
4. **UI Patterns**: Expo Image, Pressable, and Safe Area handling (High).
5. **State & Rendering**: Subscription minimization and falsy check prevention (Medium).

## Instructions
- **Optimize Lists**:
  - Always prefer `FlashList` for large datasets.
  - Memoize list items and extract callbacks outside the render loop.
  - Avoid inline objects or functions in `renderItem`.
- **Animate Efficiently**:
  - Use `Reanimated` for 60fps animations.
  - Only animate `transform` and `opacity` properties to stay on the UI thread.
  - Use `useDerivedValue` for computed animation states.
- **Native UI First**:
  - Use `expo-image` for all image rendering.
  - Prefer `Pressable` over legacy `TouchableOpacity`.
  - Use native modals and context menus where available.
- **Safe Area Management**: Properly handle safe area insets in `ScrollView` and headers.

## Best Practices
- **Explicit Conditionals**: Avoid `render && <Component />` if `render` could be a falsy value like `0` (use ternary or explicit boolean instead).
- **GPU-Only Animations**: Keep animation logic away from the JavaScript thread.
- **Stabilize References**: Use `useCallback` or hoist functions to prevent list items from re-rendering.

## Anti-Patterns
- **JS Navigators**: Using JS-based stacks when native stack navigators are available.
- **Inline Styles in Lists**: Creating new style objects in every render of a list item.
- **Failing to Virtualize**: Rendering long lists without a virtualization engine.

## Related Resources
- **Related Skills**: `vercel-react-best-practices`, `web-design-guidelines`
