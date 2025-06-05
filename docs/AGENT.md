# 🤖 Agent Development Guide

## 📊 Progress: 2/11 Complete

### ✅ Completed
- [x] s00_auth_api
- [x] s01_departments_api
- [x] s02_programs_api

### 🔄 Next Sessions
- [ ] s03_campuses_api ← **START HERE**
- [ ] s03_campuses_api
- [ ] s04_tuition_api
- [ ] s05_scholarships_api
- [ ] s06_applications_api
- [ ] s07_documents_api
- [ ] s08_ai_search_api
- [ ] s09_ai_application_api
- [ ] s10_dashboard_stats_api

---

## 🏗️ Standard Implementation Pattern

### File Creation Order (for any session)
1. `src/types/[entity].ts` - TypeScript interfaces
2. `src/schemas/[entity].ts` - Zod validation schemas
3. `src/services/[entity].service.ts` - Business logic with Bun SQL
4. `src/handlers/[entity].handler.ts` - Request handlers (no try-catch)
5. `src/routes/[entity].ts` - OpenAPI routes with auth
6. Update `src/routes/index.ts` - Add new routes

### Code Patterns
```typescript
// Service Pattern
export class EntityService {
  async findAll(): Promise<Entity[]> {
    return db`SELECT * FROM entities WHERE is_active = true ORDER BY name`;
  }
  async findById(id: string): Promise<Entity | null> {
    const [item] = await db`SELECT * FROM entities WHERE id = ${id}`;
    return item || null;
  }
}

// Handler Pattern (no try-catch)
export const getEntitiesHandler = async (c: Context) => {
  const items = await service.findAll();
  return c.json({ data: items }, 200);
};

// Route Pattern
const app = new OpenAPIHono();
app.openapi(getEntitiesRoute, getEntitiesHandler); // Public
app.use("*", authMiddleware); // Protected routes below
app.use("*", requireRole("admin", "super_admin"));
app.openapi(createEntityRoute, createEntityHandler);
export default app;
```

---

## 📋 Session Details

### s01: Departments API (35-45 min)
**Files**: types/departments.ts, schemas/departments.ts, services/departments.service.ts, handlers/departments.handler.ts, routes/departments.ts
**Endpoints**: GET /api/v1/departments (public), POST/PUT/DELETE (admin only)

### s02: Programs API (40-50 min)
**Files**: types/programs.ts, schemas/programs.ts, services/programs.service.ts, handlers/programs.handler.ts, routes/programs.ts
**Endpoints**: GET /api/v1/programs (public, with department info), POST/PUT/DELETE (admin only)
**Notes**: Department JOINs, filtering by department_code

### s03: Campuses API (35-45 min)
**Files**: types/campuses.ts, schemas/campuses.ts, services/campuses.service.ts, handlers/campuses.handler.ts, routes/campuses.ts
**Endpoints**: GET /api/v1/campuses (public, with foundation fees), POST/PUT/DELETE (admin only)
**Notes**: Foundation fee calculations, campus discount logic

### s04: Tuition API (50-60 min) - COMPLEX
**Files**: types/tuition.ts, schemas/tuition.ts, services/tuition.service.ts, handlers/tuition.handler.ts, routes/tuition.ts
**Endpoints**: GET /api/v1/tuition (by program_code & campus_code), POST /api/v1/tuition/calculate
**Notes**: Complex JOINs (programs + campuses + progressive_tuition + foundation_fees), campus discounts

### s05: Scholarships API (30-40 min)
**Files**: types/scholarships.ts, schemas/scholarships.ts, services/scholarships.service.ts, handlers/scholarships.handler.ts, routes/scholarships.ts
**Endpoints**: GET /api/v1/scholarships (public), POST/PUT/DELETE (admin), POST /api/v1/scholarships/check-eligibility (student)

### s06: Applications API (50-60 min)
**Files**: types/applications.ts, schemas/applications.ts, services/applications.service.ts, handlers/applications.handler.ts, routes/applications.ts
**Endpoints**: POST /api/v1/applications (public), GET /api/v1/applications (admin), GET /api/v1/applications/my (student), PUT /api/v1/applications/:id/status (admin)
**Notes**: Multi-level auth, ownership validation, complex JOINs

### s07: Documents API (40-50 min)
**Files**: types/documents.ts, schemas/documents.ts, services/documents.service.ts, handlers/documents.handler.ts, routes/documents.ts
**Endpoints**: POST /api/v1/documents/upload (auth), GET /api/v1/documents/:id (auth), DELETE /api/v1/documents/:id (owner/admin)
**Notes**: File upload/download, security validation

### s08: AI Search API (45-55 min)
**Files**: types/ai-search.ts, schemas/ai-search.ts, services/ai-search.service.ts, handlers/ai-search.handler.ts, routes/ai-search.ts
**Endpoints**: POST /api/v1/ai/search (public), GET /api/v1/ai/suggestions (public)
**Notes**: AI integration, natural language processing

### s09: AI Application API (45-55 min)
**Files**: types/ai-application.ts, schemas/ai-application.ts, services/ai-application.service.ts, handlers/ai-application.handler.ts, routes/ai-application.ts
**Endpoints**: POST /api/v1/ai/application/analyze (auth), GET /api/v1/ai/application/recommendations (auth)
**Notes**: AI processing, eligibility assessment

### s10: Analytics API (40-50 min)
**Files**: types/analytics.ts, schemas/analytics.ts, services/analytics.service.ts, handlers/analytics.handler.ts, routes/analytics.ts
**Endpoints**: GET /api/v1/analytics/dashboard (admin), GET /api/v1/analytics/applications (admin), GET /api/v1/analytics/programs (admin)
**Notes**: Complex aggregations, performance optimization

---

## 🚨 Critical Rules
- **Use Bun SQL** (not postgres.js): `import { db } from "@config/database"`
- **No try-catch** in handlers (middleware handles errors)
- **Follow auth patterns** from existing auth system
- **Test endpoints** before moving to next session
- **Update progress** by checking off completed sessions

## 🧪 Quick Test
```bash
# Start dev
make services-up && make dev

# Test endpoint
curl http://localhost:3000/api/v1/[entity]

# Test with auth
curl -X POST http://localhost:3000/api/v1/[entity] \
  -H "Authorization: Bearer [token]" \
  -H "Content-Type: application/json" \
  -d '{"field":"value"}'
```

**Workflow**: Find next unchecked session above → Create 6 files → Test endpoints → Check off → Repeat
