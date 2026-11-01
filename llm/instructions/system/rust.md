This document serves as a comprehensive guide for development teams and AI models to write high-quality, idiomatic, and performant Rust code. It synthesizes the principles of "Clean Code" with Rust’s unique systems-level constraints.

---

# Rust Engineering Standard: Writing Idiomatic & Maintainable Code

## 1. Core Philosophy

Writing "Clean Rust" is not just about aesthetics; it is about leveraging the type system to enforce safety and performance at compile time.

- **Safety First:** Use the borrow checker to eliminate data races and memory leaks.
- **Zero-Cost Abstractions:** Prefer high-level constructs (iterators, closures) that compile down to efficient machine code.
- **Explicit over Implicit:** Rust favors being explicit about errors, mutations, and ownership transfers.

---

## 2. Code Style and Readability

### Naming Conventions

- **Variables/Functions/Modules:** `snake_case` (e.g., `calculate_total_price`).
- **Structs/Enums/Traits/Types:** `PascalCase` (e.g., `UserAccount`).
- **Constants/Statics:** `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`).

### Formatting

- **Always use `rustfmt`:** Run `cargo fmt` before every commit. Consistency is more important than personal preference.
- **Meaningful Names:** Avoid single-letter variables except in very short closures or mathematical contexts.
  - _Bad:_ `let x = 10;`
  - _Good:_ `let item_count = 10;`

---

## 3. Memory Management: Ownership & Borrowing

Understanding the **Stack** vs. **Heap** is critical for Rust performance.

### The Stack (Default)

- Used for values with a known size at compile time (primitives, arrays).
- Extremely fast (LIFO).
- **Instruction:** Prefer stack allocation unless the data is large or needs to outlive the current function scope.

### The Heap (`Box<T>`)

- Used for dynamic sizing or transferring ownership of large data without copying.
- **Instruction:** Use `Box<T>` for recursive types or when you need to put a large struct on the heap to avoid stack overflow.

### Borrowing Rules

- **Rule 1:** You can have either one mutable reference (`&mut T`) OR any number of immutable references (`&T`).
- **Rule 2:** References must always be valid (lifetimes).
- **Instruction:** Prefer borrowing (`&T`) over cloning (`.clone()`). Only clone when you truly need a separate copy of the data.

---

## 4. The Type System & Idiomatic Patterns

### Use Enums for State

Avoid using magic numbers or strings to represent state. Use Enums to make states mutually exclusive.

```rust
// Good
enum HttpStatus {
    Success,
    NotFound,
    InternalError,
}
```

### Pattern Matching

Use `match` instead of complex `if-else` chains. It ensures exhaustiveness (the compiler forces you to handle every case).

```rust
match status {
    HttpStatus::Success => handle_ok(),
    _ => handle_error(),
}
```

### Traits and Generics

- Use **Traits** to define shared behavior (interfaces).
- Use **Generics** with trait bounds (`T: Display`) to write reusable code without performance hits (monomorphization).
- **AsRef & Borrow:** Use `AsRef<str>` in function arguments to accept both `String` and `&str` flexibly.

---

## 5. Error Handling Strategy

Rust does not have exceptions. It uses `Option<T>` and `Result<T, E>`.

### Avoid `unwrap()` and `expect()`

- **Instruction:** Never use `unwrap()` in production code unless you can prove the code will never fail (e.g., in tests).
- **Instruction:** Use the `?` operator to propagate errors up the call stack.

### Custom Error Types

For libraries, define a custom error enum and implement the `std::error::Error` trait.

```rust
#[derive(Debug)]
enum MyError {
    Io(std::io::Error),
    Parse(std::num::ParseIntError),
}
```

### Combinators

Use functional methods like `.map()`, `.and_then()`, and `.unwrap_or()` to handle `Option` and `Result` cleanly.

---

## 6. Iterators: The Rustacean Way

Avoid C-style loops with indexing. They are prone to "off-by-one" errors and include unnecessary bounds checking.

- **Instruction:** Use `.iter()`, `.map()`, `.filter()`, and `.collect()`.
- **Performance:** Iterators are often _faster_ than manual loops because the compiler can optimize away bounds checks.

```rust
// Idiomatic
let doubled: Vec<_> = nums.iter().map(|x| x * 2).collect();
```

---

## 7. Concurrency & Safety

### Send and Sync

- `Send`: Allows ownership to be transferred between threads.
- `Sync`: Allows a type to be shared between threads via references.

### Safe Shared State

- **`Arc<T>`:** Atomic Reference Counter for shared ownership across threads.
- **`Mutex<T>`:** For mutual exclusion when you need to mutate shared data.
- **Instruction:** Use `Arc<Mutex<T>>` for shared mutable state, but prefer **Channels** (`mpsc`) to communicate between threads ("Do not communicate by sharing memory; share memory by communicating").

---

## 8. Documentation and Testing

### Documentation Comments

- Use `///` for function/struct documentation.
- Use `//!` for module/crate level documentation.
- **Doc Tests:** Include examples in your documentation. Rust runs these as tests to ensure your documentation never goes out of date.

### Testing

- Place unit tests in a `mod tests` at the bottom of your file with `#[cfg(test)]`.
- Use `cargo test` to run all tests, including doc tests.

---

## 9. Common Anti-Patterns to Avoid (For AI & Teams)

1.  **Unnecessary Cloning:** Don't `.clone()` just to satisfy the borrow checker. Fix the architecture or use references.
2.  **&String vs &str:** Never use `&String` as a function argument. Use `&str` because it accepts both `String` and literals.
3.  **Ignoring Results:** Never let a `Result` go unused. Use `let _ = ...` if you intentionally want to ignore it, but ideally, handle the error.
4.  **Large Bloated Functions:** Follow the **Single Responsibility Principle**. Break logic into small, testable functions.
5.  **Over-using `RefCell`:** If you find yourself using `RefCell` or `unsafe` everywhere, your ownership model is likely flawed.

---

## 10. Tooling Checklist

- **`cargo check`:** Run frequently to catch type errors without waiting for a full build.
- **`cargo clippy`:** The most important tool. It catches non-idiomatic code and common bugs. **Fix all Clippy warnings.**
- **`cargo fmt`:** Ensure code style compliance.
- **`cargo test`:** Ensure logic correctness.

---

### Instructions for AI Agents

When writing Rust code:

1.  **Prioritize `&str` and `&[T]`** over `String` and `Vec<T>` for function arguments.
2.  **Use `?` for error propagation** instead of matching every `Result`.
3.  **Implement `From` trait** for error conversions between types.
4.  **Prefer functional iterators** over `for i in 0..len` loops.
5.  **Always include a `# Examples` section** in documentation for public functions.
6.  **Check for `mut` necessity:** Do not mark variables as `mut` if they aren't changed.
