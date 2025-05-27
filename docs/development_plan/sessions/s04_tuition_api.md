# Session 4: Progressive Tuition API

## 🎯 Goal: Progressive Tuition System

## 🔧 Tasks (40-50 min)

1. **Types** - `src/types/database.ts`
   - `ProgressiveTuition`, `TuitionCalculation` interfaces
   - Complex tuition calculation types

2. **Schemas** - `src/schemas/dashboard/tuition.ts`
   - Progressive tuition schemas
   - Calculation request/response schemas

3. **Service** - `src/services/database/tuition.service.ts`
   - Methods: `findByProgramCampus()`, `calculateTuition()`
   - Complex JOIN queries with programs + campuses

4. **Handlers** - `src/handlers/dashboard/tuition.handler.ts`
   - Tuition calculation logic
   - Multi-table relationship handling

5. **Routes** - `src/routes/dashboard/tuition.ts`
   - GET tuition by program/campus
   - POST calculate tuition

6. **Integration**
   - Update `src/routes/dashboard/index.ts`

## 📚 References
- Database: `docs/database/02_schema.sql` (progressive_tuition table)
- Patterns: `patterns/bun_sql_patterns.md` (complex JOINs)
- Business Logic: FPT University tuition structure

## ✅ Success Criteria
- [ ] GET /api/v1/dashboard/tuition (by program/campus)
- [ ] POST /api/v1/dashboard/tuition/calculate (calculations)
- [ ] Complex JOIN queries work correctly
- [ ] Tuition calculations accurate
- [ ] No TypeScript/Biome errors

## 🚀 Next: s05_scholarships_api (Scholarships management)
