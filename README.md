# 🎓 FPT University 2025 Admission System

Core Backend API for FPT University 2025 Admission System with integrated AI chatbot built with **Bun**, **Hono**, **PostgreSQL**, and **TypeScript**.

## ✨ Features

### 🔐 Authentication & Authorization
- **JWT Authentication** - Secure token-based authentication
- **Role-based Access Control** - Student, Admin, Staff, Super Admin roles
- **Password Security** - Bcrypt hashing with strength validation
- **Session Management** - HTTP-only cookies + Bearer tokens

### 🏫 University Management
- **Departments** - Academic department management
- **Programs** - Study program catalog with relationships
- **Campuses** - Multi-campus support with foundation fees
- **Tuition** - Progressive tuition fee management
- **Scholarships** - Scholarship program management

### 📋 Application System
- **Applications** - Student application processing
- **Document Upload** - File handling for application documents
- **Multi-source Support** - Chatbot, website, manual applications
- **Status Tracking** - Application lifecycle management

### 🤖 AI Integration
- **Chatbot Conversations** - AI-powered admission assistance
- **Smart Search** - AI-enhanced information retrieval
- **Application Processing** - AI-assisted application review
- **Analytics** - Dashboard statistics and insights

### 🛠️ Technical Features
- 🏃‍♂️ **Bun Runtime** - Ultra-fast JavaScript runtime
- 🔥 **Hono Framework** - Lightweight, fast web framework
- 🗄️ **PostgreSQL** - Robust database with Bun SQL
- 📝 **TypeScript** - Full type safety
- 📚 **OpenAPI 3.0** - Auto-generated API documentation with Scalar UI
- 🧪 **Testing** - Bun test runner setup
- 🔍 **Logging** - Pino logger with request tracing
- 🛡️ **Security** - Rate limiting, CORS, security headers
- 🔧 **Development** - Hot reload, linting, formatting
- 🐳 **Docker** - Ready for containerization

## 🚀 Quick Start

```bash
# One-time setup
make setup

# Install and setup direnv (recommended)
brew install direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc  # or ~/.zshrc
direnv allow

# Start development
make dev
```

## Commands

```bash
make dev             # Start development server
make test            # Run tests
make build           # Build for production
make start           # Start production server locally
make services-up     # Start development services (PostgreSQL + Redis)
make services-down   # Stop development services
make docker-info     # Show Docker build information
make help            # Show all commands
```

## Environment Management

Simple, single-file approach:

```bash
# Copy and customize
cp .env.example .env

# Development (default settings work out of box)
make dev

# Production (uncomment production section in .env)
cd docker/prod && ./deploy.sh
```

**`.env.example`** contains both development and production settings with clear sections.

## API Docs

- **Documentation**: http://localhost:3000/docs
- **Health Check**: http://localhost:3000/health



## 🛠️ Tech Stack

- **Runtime**: [Bun](https://bun.sh/) - Ultra-fast JavaScript runtime
- **Framework**: [Hono](https://hono.dev/) - Lightweight web framework
- **Database**: [PostgreSQL 17](https://www.postgresql.org/) + [Bun SQL](https://bun.sh/docs/api/sql) (built-in driver)
- **Validation**: [Zod](https://zod.dev/) - TypeScript-first schema validation
- **API Docs**: [OpenAPI 3.0](https://swagger.io/specification/) + [Scalar UI](https://scalar.com/)
- **Logging**: [Pino](https://getpino.io/) - Fast JSON logger
- **Testing**: Bun test runner
- **Code Quality**: [Biome](https://biomejs.dev/) - Fast linter & formatter
- **Git Hooks**: [Husky](https://typicode.github.io/husky/) + lint-staged
