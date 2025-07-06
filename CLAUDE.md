# Ruff

## Project Description

Ruff is a Ruby library that provides an implementation of one-shot algebraic effect handlers. Algebraic effect handlers are a way to implement local control flow, which can be used to create powerful abstractions such as async/await, generators, and coroutines. Ruff's effects are "one-shot," meaning that a delimited continuation can be resumed at most once.

The library also features subtyping on effects, allowing for the creation of effect hierarchies. Several pre-defined effects and handlers are included, such as `State`, `Defer`, `Async`, and `Call1cc`.

## Development

This project uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) and [direnv](https://direnv.net/) to provide a reproducible development environment.

If you are a Nix user and have `direnv` installed, you can simply run `direnv allow` in the project root. This will automatically install all the required dependencies, including Ruby and the necessary gems, into a sandboxed environment. You will not need to run `bundle install` separately.

For non-Nix users, you can follow the standard Ruby development setup:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Nymphium/ruff.git
    cd ruff
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    ```

3.  **Run the tests:**
    ```bash
    bundle exec rspec
    ```

## Instructions for LLMs

When working with the Ruff codebase, please adhere to the following guidelines:

*   **Understand the Core Concepts:** Before making changes, ensure you have a conceptual understanding of algebraic effects and handlers, and one-shot continuations. The `README.md` file provides a good starting point.
*   **Follow Existing Patterns:** The codebase has a clear structure. New effects, handlers, or other components should follow the existing patterns and conventions.
*   **Testing is Crucial:** Any new feature or bug fix must be accompanied by tests. The project uses RSpec for testing. Please add new tests to the `spec` directory and ensure all existing tests pass.
*   **Documentation:** For any user-facing changes, update the documentation. The project uses YARD for documentation.
*   **Dependencies:** Do not add new gem dependencies without a strong justification. This is a lightweight library and should remain so.
*   **Code Style:** The project follows standard Ruby style guidelines.
*   **Commit Messages:** Write clear and concise commit messages that explain the "why" behind the changes.
