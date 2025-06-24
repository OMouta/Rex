# Contributing to Rex

Thank you for your interest in contributing to Rex! We welcome all contributions—code, documentation, bug reports, and suggestions. This guide will help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)
- [Testing](#testing)
- [Documentation](#documentation)
- [Community](#community)

---

## Code of Conduct

By participating, you agree to abide by our [Code of Conduct](.github/CODE_OF_CONDUCT.md).

## Getting Started

1. **Fork the repository** and clone your fork locally.
2. **Install dependencies** (if any) and set up your Roblox Studio environment.
3. **Explore the `/Rex` and `/src/Client` directories** for core framework and examples.
4. **Read the [README.md](README.md)** for an overview and usage instructions.

## How to Contribute

- **Bug Reports:** Use GitHub Issues to report bugs. Please include steps to reproduce and relevant logs or screenshots.
- **Feature Requests:** Open an issue with `[Feature]` in the title and describe your idea.
- **Pull Requests:**
  1. Create a feature branch (`git checkout -b feature/your-feature`)
  2. Make your changes (see [Coding Standards](#coding-standards))
  3. Add or update tests/examples if needed
  4. Commit with a clear message (see [Commit Messages](#commit-messages))
  5. Push and open a Pull Request

## Coding Standards

- **Language:** Use idiomatic Luau (Roblox Lua) with type annotations where possible.
- **Formatting:**
  - 2 spaces for indentation
  - Use `local` for variables and functions unless global is required
  - Prefer `Rex` idioms (see docs)
- **Documentation:**
  - Document public APIs with comments
  - Update `/docs` if you add or change features

## Commit Messages

- Use clear, descriptive commit messages
- Prefix with type: `fix:`, `feat:`, `docs:`, `refactor:`, `test:`, `chore:`
- Example: `feat: add useAsyncState for async data fetching`

## Pull Requests

- Reference related issues (e.g., `Closes #123`)
- Ensure your branch is up to date with `main`
- Pass all CI checks (if enabled)
- Fill out the PR template

## Testing

- Test your changes in Roblox Studio
- Add or update example scripts in `/src/Client` if relevant
- Manual and automated tests are both welcome

## Documentation

- Update `/docs` and `README.md` for any user-facing changes
- Add code examples where possible

## Community

- Join discussions in GitHub Issues
- Be respectful and constructive
- See [Code of Conduct](.github/CODE_OF_CONDUCT.md)

---

Thank you for helping make Rex better!
