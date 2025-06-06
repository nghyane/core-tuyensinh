# Optimized Makefile for Personal API Starter
.SILENT:

# Variables
PROJECT_NAME := personal-api-starter
DOCKER_COMPOSE_DEV := docker/dev/docker-compose.yml
BUILD_DIR := dist

.PHONY: help install dev test build clean services-up services-down services-status db-reset setup start fix direnv-setup db-init db-seed db-setup db-reset db-rebuild

help: ## Show available commands
	echo 'Usage: make [target]'
	echo ''
	echo 'Available targets:'
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Dependencies
node_modules: package.json bun.lock
	echo "📦 Installing dependencies..."
	bun install
	touch node_modules

install: node_modules ## Install dependencies

# Development
dev: node_modules ## Start development server
	echo "🚀 Starting development server..."
	bun run --watch src/index.ts

# Code Quality
fix: node_modules ## Check and auto-fix code issues
	echo "🔧 Checking and fixing code issues..."
	bunx biome check --write .
	echo "🔍 Running TypeScript check..."
	bunx tsc --noEmit

# Testing
test: node_modules ## Run tests
	echo "🧪 Running tests..."
	bun test

# Build
$(BUILD_DIR): src/index.ts src/**/*.ts
	echo "🏗️  Building for production..."
	bun build src/index.ts --outdir ./$(BUILD_DIR) --target bun
	touch $(BUILD_DIR)

build: $(BUILD_DIR) ## Build for production

clean: ## Clean build artifacts
	echo "🧹 Cleaning build artifacts..."
	rm -rf $(BUILD_DIR) node_modules/.cache

# Docker services
services-up: ## Start development services
	echo "🐳 Starting development services..."
	docker-compose -f $(DOCKER_COMPOSE_DEV) up -d
	echo "⏳ Waiting for services to be ready..."
	echo "📊 Checking service health..."
	for i in $$(seq 1 30); do \
		if docker-compose -f $(DOCKER_COMPOSE_DEV) ps | grep -q "healthy"; then \
			echo "✅ Services are ready!"; \
			break; \
		fi; \
		echo "⏳ Services starting... (attempt $$i/30)"; \
		sleep 2; \
	done

services-down: ## Stop development services
	echo "🛑 Stopping development services..."
	docker-compose -f $(DOCKER_COMPOSE_DEV) down

services-status: ## Check development services status
	echo "📊 Checking services status..."
	docker-compose -f $(DOCKER_COMPOSE_DEV) ps



# Project setup
setup: install ## Initial project setup
	echo "📋 Setting up environment files..."
	if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "📄 Created .env from .env.example"; \
	else \
		echo "📄 .env already exists"; \
	fi
	echo "🔧 Setting up direnv..."
	if command -v direnv >/dev/null 2>&1; then \
		if [ ! -f .envrc ]; then \
			echo "⚠️  .envrc file not found"; \
		else \
			direnv allow .; \
			echo "✅ direnv configured and allowed"; \
		fi \
	else \
		echo "⚠️  direnv not installed. Install with: brew install direnv"; \
		echo "💡 Add 'eval \"\$$(direnv hook bash)\"' to your shell config"; \
	fi
	$(MAKE) services-up
	echo "✅ Project setup complete!"
	echo "🚀 Run 'make dev' to start development"

# Environment setup
direnv-setup: ## Setup and configure direnv
	echo "🔧 Setting up direnv..."
	if command -v direnv >/dev/null 2>&1; then \
		if [ ! -f .envrc ]; then \
			echo "❌ .envrc file not found"; \
			exit 1; \
		else \
			direnv allow .; \
			echo "✅ direnv configured and allowed"; \
			echo "💡 Environment variables will be loaded automatically"; \
		fi \
	else \
		echo "❌ direnv not installed"; \
		echo "📦 Install with: brew install direnv"; \
		echo "🔧 Add to your shell config:"; \
		echo "   # For bash: echo 'eval \"\$$(direnv hook bash)\"' >> ~/.bashrc"; \
		echo "   # For zsh:  echo 'eval \"\$$(direnv hook zsh)\"' >> ~/.zshrc"; \
		exit 1; \
	fi

# Database Management (Optimized scripts)
db-init: ## Initialize database with schema
	@if [ -f .env ]; then \
		set -a && source .env && set +a; \
		if [ -z "$$DATABASE_URL" ]; then \
			echo "❌ DATABASE_URL not set in .env file"; exit 1; \
		fi; \
		./scripts/db-init.sh; \
	else \
		echo "❌ .env file not found. Run 'make setup' first."; exit 1; \
	fi

db-seed: ## Populate database with seed data
	@if [ -f .env ]; then \
		set -a && source .env && set +a; \
		if [ -z "$$DATABASE_URL" ]; then \
			echo "❌ DATABASE_URL not set in .env file"; exit 1; \
		fi; \
		./scripts/db-seed.sh; \
	else \
		echo "❌ .env file not found. Run 'make setup' first."; exit 1; \
	fi

db-setup: db-init db-seed ## Complete database setup (init + seed)

db-reset: ## Reset database (drop all tables)
	@if [ -f .env ]; then \
		set -a && source .env && set +a; \
		if [ -z "$$DATABASE_URL" ]; then \
			echo "❌ DATABASE_URL not set in .env file"; exit 1; \
		fi; \
		./scripts/db-reset.sh; \
	else \
		echo "❌ .env file not found. Run 'make setup' first."; exit 1; \
	fi

db-rebuild: ## Complete database rebuild (reset + init + seed)
	@if [ -f .env ]; then \
		set -a && source .env && set +a; \
		if [ -z "$$DATABASE_URL" ]; then \
			echo "❌ DATABASE_URL not set in .env file"; exit 1; \
		fi; \
		chmod +x ./scripts/db-rebuild.sh; \
		./scripts/db-rebuild.sh; \
	else \
		echo "❌ .env file not found. Run 'make setup' first."; exit 1; \
	fi

# Production
start: build ## Start production server locally
	echo "🚀 Starting production server..."
	bun run $(BUILD_DIR)/index.js
