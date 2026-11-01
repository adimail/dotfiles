Audit this codebase for code quality, architectural soundness, and maintainability.

Evaluate:
- **Code Quality:** Clean Code, SOLID, DRY, KISS, separation of concerns, naming, duplication, complexity, and dead code.
- **Architecture:** Component and module boundaries, dependency direction, coupling, cohesion, abstractions, and separation of responsibilities.
- **Data Flow:** How data moves through the application, state management, API interactions, validation, transformations, and persistence. Identify unnecessary complexity and inconsistent patterns.
- **Modularity:** Whether modules are reusable, independently understandable, appropriately sized, and easy to test or replace.
- **Design Decisions:** Unnecessary abstractions, overengineering, tightly coupled logic, repeated patterns, and simpler alternatives.
- **Reliability:** Edge cases, race conditions, resource management, security concerns, and failure handling where relevant.
- **Maintainability:** Testability, readability, consistency, and how easily the codebase can accommodate future changes.

### Output

Produce a concise, prioritized audit containing:

1. **Overall Assessment:** Brief verdict on the codebase's quality and its biggest weaknesses.
2. **Findings:** Specific issues with file paths, relevant functions or components, why each issue matters, and a recommended improvement.
3. **Architecture & Data Flow:** Key structural problems and opportunities to simplify or improve how the application is organized.
4. **Recommended Changes:** A prioritized list of actionable improvements, ordered by impact and effort.

For every finding, classify its severity as Critical, High, Medium, or Low. Distinguish actual problems from optional improvements. Support findings with evidence from the codebase; do not speculate or recommend changes merely to follow a principle.

**Constraints:**
- VERY IMPORTANT: Prefer the simplest solution that solves the actual problem.
- Inspect the existing implementation before drawing conclusions.
- Evaluate the application as a whole, not just individual files.
- Do not recommend rewrites, abstractions, or design patterns without a clear justification.
- Avoid generic advice, repeated findings, excessive explanations, and unnecessary documentation.
- Do not modify the code. Report findings and recommendations only.
