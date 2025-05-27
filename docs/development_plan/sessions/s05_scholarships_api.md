# Session 5: Scholarships API

## 🎯 Goal: Scholarships Management

## 🔧 Tasks (30-40 min)

1. **Types** - `src/types/database.ts`
   - `Scholarship`, `ScholarshipApplication` interfaces
   - Scholarship calculation types

2. **Schemas** - `src/schemas/dashboard/scholarships.ts`
   - Scholarship CRUD schemas
   - Application/eligibility schemas

3. **Service** - `src/services/database/scholarships.service.ts`
   - Methods: `findAll()`, `findById()`, `checkEligibility()`
   - Scholarship calculation logic

4. **Handlers** - `src/handlers/dashboard/scholarships.handler.ts`
   - Scholarship management
   - Eligibility checking

5. **Routes** - `src/routes/dashboard/scholarships.ts`
   - Methods: GET, POST, PUT, DELETE
   - Eligibility check endpoints

6. **Integration**
   - Update `src/routes/dashboard/index.ts`

## 📚 References
- Database: `docs/database/02_schema.sql` (scholarships table)
- Patterns: `patterns/bun_sql_patterns.md`
- Business Logic: FPT University scholarship rules

## ✅ Success Criteria
- [ ] GET /api/v1/dashboard/scholarships (200)
- [ ] POST /api/v1/dashboard/scholarships (creates)
- [ ] PUT /api/v1/dashboard/scholarships/:id (updates)
- [ ] DELETE /api/v1/dashboard/scholarships/:id (soft delete)
- [ ] Eligibility checking works
- [ ] No TypeScript/Biome errors

## 🚀 Next: s06_applications_api (Applications CRUD)
