# Session 8: AI Search API

## 🎯 Goal: AI-Powered Program Search

## 🔧 Tasks (45-55 min)

1. **Types** - `src/types/ai.ts`
   - `SearchQuery`, `SearchResult` interfaces
   - AI service integration types

2. **Schemas** - `src/schemas/ai/search.ts`
   - Search request/response schemas
   - AI query validation

3. **Service** - `src/services/ai/search.service.ts`
   - Methods: `searchPrograms()`, `getSuggestions()`
   - AI integration logic
   - Search result ranking

4. **Handlers** - `src/handlers/ai/search.handler.ts`
   - AI search orchestration
   - Result formatting

5. **Routes** - `src/routes/ai/search.ts`
   - POST search endpoints
   - GET suggestions endpoints

6. **Integration**
   - Create `src/routes/ai/index.ts`
   - Update `src/routes/index.ts`

## 📚 References
- Database: All program/department/campus data
- Patterns: `patterns/bun_sql_patterns.md`
- AI Integration: External AI service patterns

## ✅ Success Criteria
- [ ] POST /api/v1/ai/search (AI-powered search)
- [ ] GET /api/v1/ai/suggestions (search suggestions)
- [ ] AI integration works
- [ ] Search results accurate
- [ ] No TypeScript/Biome errors

## 🚀 Next: s09_ai_application_api (AI application processing)
