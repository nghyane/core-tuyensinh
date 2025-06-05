#!/bin/bash

# Database Reset
# Drops and recreates database schema and data
# Note: DATABASE_URL is handled by Makefile

set -e  # Exit on any error

echo "🔄 Resetting database..."

# Drop all tables (cascade to handle dependencies)
echo "Dropping existing tables..."
psql $DATABASE_URL -c "
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
"

echo "✅ Database reset complete!"
echo "💡 Run 'make db-setup' to reload schema and data"
