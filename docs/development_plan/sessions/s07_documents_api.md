# Session 7: Documents API

## 🎯 Goal: Document Upload/Download System

## 🔧 Tasks (40-50 min)

1. **Types** - `src/types/database.ts`
   - `ApplicationDocument`, `DocumentUpload` interfaces
   - File handling types

2. **Schemas** - `src/schemas/dashboard/documents.ts`
   - Document upload schemas
   - File validation schemas

3. **Service** - `src/services/database/documents.service.ts`
   - Methods: `upload()`, `download()`, `delete()`
   - File storage management
   - Document type validation

4. **Handlers** - `src/handlers/dashboard/documents.handler.ts`
   - File upload/download logic
   - Security validation

5. **Routes** - `src/routes/dashboard/documents.ts`
   - POST upload endpoints
   - GET download endpoints
   - DELETE remove endpoints

6. **Integration**
   - Update `src/routes/dashboard/index.ts`
   - File storage configuration

## 📚 References
- Database: `docs/database/02_schema.sql` (application_documents)
- Patterns: `patterns/bun_sql_patterns.md`
- Security: File upload best practices

## ✅ Success Criteria
- [ ] POST /api/v1/dashboard/documents/upload (file upload)
- [ ] GET /api/v1/dashboard/documents/:id (download)
- [ ] DELETE /api/v1/dashboard/documents/:id (remove)
- [ ] File validation works
- [ ] Security measures in place
- [ ] No TypeScript/Biome errors

## 🚀 Next: s08_ai_search_api (AI program search)
