# Session 3: Campuses API

## 🎯 Goal: Campuses CRUD + Foundation Fees

## 🔧 Tasks (35-45 min)

1. **Types** - `src/types/database.ts`
   - `Campus`, `FoundationFee` interfaces
   - `CreateCampusData`, `UpdateCampusData` types

2. **Schemas** - `src/schemas/dashboard/campuses.ts`
   - Campus CRUD schemas
   - Foundation fees nested schemas

3. **Service** - `src/services/database/campuses.service.ts`
   - Methods: `findAll()`, `findById()`, `create()`, `update()`, `softDelete()`
   - Foundation fees management

4. **Handlers** - `src/handlers/dashboard/campuses.handler.ts`
   - Follow established patterns
   - Handle foundation fees operations

5. **Routes** - `src/routes/dashboard/campuses.ts`
   - Methods: GET, POST, PUT, DELETE
   - Foundation fees endpoints

6. **Integration**
   - Update `src/routes/dashboard/index.ts`

## 📚 References
- Database: `docs/database/02_schema.sql` (campuses + foundation_fees)
- Patterns: `patterns/bun_sql_patterns.md`
- Examples: Previous session implementations

## ✅ Success Criteria
- [ ] GET /api/v1/dashboard/campuses (200)
- [ ] POST /api/v1/dashboard/campuses (creates)
- [ ] PUT /api/v1/dashboard/campuses/:id (updates)
- [ ] DELETE /api/v1/dashboard/campuses/:id (soft delete)
- [ ] Foundation fees CRUD operations
- [ ] No TypeScript/Biome errors

## 🚀 Next: s04_tuition_api (Progressive tuition system)
