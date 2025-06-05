# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-01-27

### Added
- **📚 Programs API**: Complete CRUD operations for academic programs
  - GET /api/v1/programs (public) - List all programs with department info
  - GET /api/v1/programs/:id (public) - Get specific program details
  - POST /api/v1/programs (admin) - Create new programs
  - PUT /api/v1/programs/:id (admin) - Update existing programs
  - DELETE /api/v1/programs/:id (admin) - Soft delete programs
  - Department filtering via ?department_code query parameter
  - Full department information included in responses via JOIN queries
  - Validation for program codes, duration (1-6 years), and department existence
  - Admin-only access for create/update/delete operations

## [1.1.0] - 2025-01-27

### Added
- **🔐 Authentication System**: Complete JWT + role-based authentication
  - User registration and login with secure password hashing
  - JWT token generation and verification
  - Role-based access control (student, admin, staff, super_admin)
  - Token refresh mechanism
  - Protected routes with auth middleware
- **🏢 Departments API**: Complete CRUD operations for university departments
  - GET /api/v1/departments (public) - List all departments
  - GET /api/v1/departments/:id (public) - Get specific department
  - POST /api/v1/departments (admin) - Create new departments
  - PUT /api/v1/departments/:id (admin) - Update existing departments
  - DELETE /api/v1/departments/:id (admin) - Soft delete departments
- **🗄️ Database Architecture**: Complete FPT University schema (15 tables)
  - Users, departments, programs, campuses, applications
  - Progressive tuition, scholarships, admission methods
  - Chatbot conversations and message history
  - Document uploads and analytics tracking
- **🛠️ Development Workflow**: Structured 11-session development plan
  - Phase 0: Authentication (✅ Complete)
  - Phase 1: Core APIs (departments ✅, programs ✅, campuses, tuition)
  - Phase 2: Applications (scholarships, applications, documents)
  - Phase 3: AI Integration (search, processing, analytics)
- **🔧 Enhanced Configuration**:
  - Bun SQL integration (replacing postgres.js)
  - Input sanitization and validation utilities
  - Password strength validation
  - Audit logging system

### Changed
- **Project Identity**: Renamed from "AI Chatbot Backend" to "FPT University 2025 Admission System"
- **Database Driver**: Migrated from postgres.js to Bun SQL (built-in driver)
- **API Documentation**: Using Scalar UI instead of Swagger UI
- **Architecture**: Clean architecture with handlers, routes, middleware following Hono best practices

### Technical Stack Updates
- **Runtime**: Bun (JavaScript runtime with built-in bundler and SQL driver)
- **Framework**: Hono (lightweight web framework)
- **Database**: PostgreSQL 17 + Bun SQL
- **Validation**: Zod + @hono/zod-openapi for type-safe APIs
- **Logging**: Pino for structured logging
- **Code Quality**: Biome (linting/formatting)
- **Testing**: Bun test runner
- **API Docs**: OpenAPI 3.0 + Scalar UI

## [1.0.0] - 2025-01-25

### Added
- **🤖 AI Chatbot Foundation**: Complete API foundation for chatbot applications
- **🔄 AI Service Integration**: API client for external AI services
- **💬 Conversation Management**: Chat session and message handling
- **👤 User Session Tracking**: UUID-based session management
- **📝 Message History**: Persistent conversation storage in PostgreSQL
- **🌐 API Gateway**: Proxy and manage AI service requests
- **⚡ Bun Runtime**: Fast JavaScript runtime with built-in bundler
- **🔥 Hono Framework**: Lightweight web framework with TypeScript support
- **🗄️ PostgreSQL 17**: Latest database with UUIDv8 support
- **📚 OpenAPI Documentation**: Auto-generated docs with Scalar UI
- **📝 TypeScript Support**: Strict type checking and modern syntax
- **📊 Pino Logging**: Structured logging with request tracing
- **🎨 Biome Tooling**: Fast linting and formatting
- **🐳 Docker Support**: Development and production containers
- **🧪 Testing Setup**: Comprehensive test suite with Bun test
- **🪝 Pre-commit Hooks**: Automated code quality checks with Husky
- **❤️ Health Check Endpoints**: Monitoring and status endpoints
- **🛡️ Error Handling**: Centralized error management
- **🚦 Rate Limiting**: API protection and security
- **⚙️ Environment Configuration**: Flexible config management
- **🚀 Production Ready**: Optimized build and deployment setup

### Features
- **External AI Integration**: API client for communicating with AI services
- **Chat Session Management**: Complete conversation lifecycle handling
- **Message Persistence**: Full conversation history storage
- **User Management**: Session-based user tracking with UUIDs
- **API Gateway Pattern**: Proxy requests to external AI services
- **Handler-based Architecture**: Following Hono best practices
- **Type-safe API**: Zod validation for all endpoints
- **Request ID Tracking**: Full request correlation and tracing
- **Comprehensive Error Responses**: Detailed error handling
- **Auto-generated OpenAPI**: Complete API documentation
- **Docker Compose**: Local development environment
- **CI/CD Ready**: Production deployment configuration
