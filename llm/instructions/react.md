# The Definitive Guide to Production-Ready React Architecture

**Version:** 1.0
**Author:** Senior Software Engineering Lead
**Target Audience:** Frontend Engineering Team

## 1. Introduction

This document outlines the mandatory coding standards, architectural patterns, and best practices for developing robust, scalable React applications. Adherence to these guidelines is required to ensure codebase maintainability, prevent technical debt, optimize performance, and guarantee a superior user experience.

---

## 2. Project Architecture & File Structure

A predictable file structure reduces cognitive load for new developers and ensures consistency.

### 2.1. Folder Organization

Do not over-engineer the structure initially, but adhere to semantic grouping.

- **`src/components/`**: Contains all React components.
  - _Sub-folders:_ Group by feature (e.g., `src/components/auth/`, `src/components/dashboard/`) or by UI primitive (e.g., `src/components/ui/Button.tsx`).
- **`src/lib/`**: Contains pure utility functions and configuration.
  - `constants.ts`: For all hard-coded values.
  - `utils.ts`: For stateless helper functions (e.g., string formatting, date manipulation).
- **`src/hooks/`**: Contains custom React hooks (reusable stateful logic).
- **`src/contexts/`** (or `src/stores/`): For global state management providers.

### 2.2. Management of "Magic" Values

**Rule:** Never use hard-coded strings or numbers ("magic values") directly inside component logic.

- **Why:** It creates maintenance nightmares and makes code difficult to refactor.
- **Implementation:**
  - Define values in `src/lib/constants.ts`.
  - Use `UPPER_SNAKE_CASE` for constants.
  - **Example:** Instead of `if (todos.length > 3)`, use `if (todos.length > MAX_FREE_TODOS)`.

---

## 3. Component Design Principles

### 3.1. When to Create Components

Create components in two scenarios:

1.  **Reusability:** When a UI element (like a Button or Card) appears in multiple places with slight variations.
2.  **Organization:** To break down a massive file. Even if a `Header` or `Sidebar` is used only once, extract it to keep the parent page/component readable.

### 3.2. The "Dumb" Component Pattern

Keep components—especially reusable ones—"dumb" (presentational).

- **Rule:** Components should not calculate complex logic based on props if that logic ties them to a specific business use case.
- **Example:** Do not pass a list of `todos` to a `StatusBar` to calculate percentage inside. Calculate the percentage in the parent and pass `progress={50}` to the `StatusBar`. This makes the `StatusBar` reusable for _any_ progress (e.g., file uploads), not just todos.

### 3.3. Avoid Unnecessary Markup

**Rule:** Avoid "Div Soup." Do not wrap returned JSX in a `<div>` unless it is required for styling (CSS Grid/Flexbox parentage).

- **Implementation:** Use React Fragments (`<></>` or `<React.Fragment>`) to group elements without adding nodes to the DOM.

### 3.4. Styling Isolation (The Layout Rule)

**Rule:** A reusable component must **never** include external layout styles (margins, positioning).

- **Why:** Adding `margin-bottom` to a `Button` component restricts its reusability in contexts where that margin is unwanted.
- **Implementation:**
  - The component defines its _internal_ look (padding, color, border).
  - The _parent_ component determines the layout/spacing.
  - Use a wrapper `div` in the parent or accept a `className` prop and merge it using a utility like `clsx` or `tailwind-merge`.

---

## 4. State Management Strategy

State is the most common source of bugs. Follow this hierarchy of state placement:

### 4.1. URL State (Highest Priority)

**Rule:** If the data represents a filter, pagination index, active tab, or sorting order, **put it in the URL**, not `useState`.

- **Why:** Allows users to bookmark and share specific views. It serves as a single source of truth.

### 4.2. Server State

**Rule:** Do not fetch data inside `useEffect` and store it in `useState`.

- **Implementation:** Use **React Query (TanStack Query)**, **SWR**, or **Next.js** server components.
- **Why:** Manual fetching lacks caching, race-condition handling, and automatic re-validation. It leads to "waterfall" requests and poor UX.

### 4.3. Derived State

**Rule:** Never store state that can be calculated from existing state.

- **Anti-Pattern:** Storing `todos` AND `completedTodosCount` in state.
- **Solution:** Store `todos`. Calculate `const completedCount = todos.filter(...)` during the render. Use `useMemo` if the calculation is expensive.

### 4.4. Single Source of Truth

**Rule:** When tracking a selected item from a list, store the **ID**, not the object.

- **Anti-Pattern:** `const [selectedTodo, setSelectedTodo] = useState(todoObject)`.
- **Risk:** If the original todo updates, the `selectedTodo` state becomes stale/out-of-sync.
- **Solution:** `const [selectedId, setSelectedId] = useState(id)`. Derive the object: `const selectedTodo = todos.find(t => t.id === selectedId)`.

### 4.5. The Updater Pattern

**Rule:** When setting state based on the _previous_ state, always use the functional updater.

- **Implementation:** `setCount(prev => prev + 1)` instead of `setCount(count + 1)`.
- **Why:** Prevents batching issues and stale closures in asynchronous operations.

---

## 5. Component Composition & Prop Drilling

**Rule:** Avoid passing props (especially state setters) through multiple layers of components that don't use them.

### 5.1. The Children Pattern

Instead of passing data down through a layout component just to reach a child, use composition.

- **Bad:** `<Sidebar user={user} />` (where Sidebar just passes user to Profile).
- **Good:** `<Sidebar><Profile user={user} /></Sidebar>`. The Sidebar accepts `children` and renders them. It doesn't need to know about `user`.

### 5.2. Event Handlers vs. Setters

**Rule:** Do not pass raw `setState` functions deep into child components.

- **Implementation:** Create a specific handler function in the parent (e.g., `handleAddTodo`) that encapsulates the logic (updating state, closing modals, logging), and pass that handler down.

---

## 6. Performance Optimization

### 6.1. Memoization

Use memoization to maintain referential stability and prevent expensive recalculations.

- **`useMemo`**: Use for expensive calculations (filtering large arrays) or to ensure an object/array reference stays stable across renders.
- **`useCallback`**: Use to memoize functions passed as props to children wrapped in `React.memo`.
- **`React.memo`**: Wrap components that render often with the same props. _Note: Only effective if the props passed to it are also memoized._

### 6.2. Render Control

Push state down as deep as possible. If only a specific button needs a loading state, that state should live in the button or a small wrapper, not in the global `App` component.

---

## 7. Side Effects (`useEffect`)

**Rule:** `useEffect` is for synchronizing with external systems (DOM, subscriptions, local storage). It is **not** for data flow.

### 7.1. Single Responsibility

Do not combine unrelated logic in one `useEffect`.

- **Bad:** One effect that updates LocalStorage AND adds an event listener.
- **Good:** Two separate effects. This makes code readable and dependencies accurate.

### 7.2. Strict Dependencies

Always include all used variables in the dependency array. If the linter complains, do not disable the rule; refactor your code (often by moving functions inside the effect or using `useCallback`).

---

## 8. TypeScript & Code Quality

### 8.1. Strict Typing

Use TypeScript to enforce constraints.

- **Props:** Define explicit interfaces.
- **Unions:** Avoid generic `string` types for status. Use Union types: `type Status = 'idle' | 'loading' | 'success' | 'error'`. This prevents impossible states (e.g., status being "loadign" due to a typo).

### 8.2. Naming Conventions

Follow standard HTML conventions for custom components.

- **Props:** Use `onEvent` (e.g., `onAddTodo`, `onClick`).
- **Handlers:** Use `handleEvent` (e.g., `handleAddTodo`, `handleClick`).

### 8.3. Logic Extraction

- **Stateless Logic:** Move to `src/lib/utils.ts` (e.g., formatting currency).
- **Stateful Logic:** Move to `src/hooks/useFeature.ts`. If you have a `useEffect` and `useState` working together to solve a specific problem (like syncing to LocalStorage), extract them into a custom hook (e.g., `useLocalStorage`). This cleans up the component and makes the logic reusable.
