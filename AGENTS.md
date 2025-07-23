# AGENTS.md - FPT Admission API Development Guide

## Build/Test/Lint Commands
- `bun run dev` - Start development server with watch mode
- `bun run build` - Build for production (outputs to ./dist)
- `bun test` - Run all tests
- `bun test tests/health.test.ts` - Run single test file
- `biome check --write` - Format and lint code (auto-fix)
- `biome format --write .` - Format only

## Code Style Guidelines
- **Formatting**: 2-space indentation, 80 char line width, semicolons always, double quotes
- **Imports**: Use path aliases (@config, @handlers, @services, etc.), organize imports enabled
- **Types**: Strict TypeScript, explicit return types for functions, use `type` for object shapes
- **Naming**: camelCase for variables/functions, PascalCase for types/interfaces, kebab-case for files
- **Files**: Use `.handler.ts`, `.service.ts`, `.middleware.ts` suffixes for clarity
- **Error Handling**: Use Hono's error handling patterns, return proper HTTP status codes
- **Comments**: JSDoc for public functions, inline comments for complex logic only
- **Testing**: Use Bun test framework, describe/it structure, test both success and error cases

## Project Structure
- Use barrel exports in index files, follow existing folder structure in src/
- Database queries in services/, HTTP handling in handlers/, validation in schemas/