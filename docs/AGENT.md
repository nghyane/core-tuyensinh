# 🤖 Agent Development Guide

## 📊 Status: 3/11 Complete → Next: s03_campuses_api

**✅ Done**: Auth, Departments, Programs | **🔄 Next**: Campuses | **📋 Remaining**: Tuition, Scholarships, Applications, Documents, AI Search, AI Application, Analytics

---

## ⚡ Quick Implementation Pattern

**Files to create (in order):**
1. `types/[entity].ts` → 2. `schemas/[entity].ts` → 3. `services/[entity].service.ts` → 4. `handlers/[entity].handler.ts` → 5. `routes/[entity].ts` → 6. Update `routes/index.ts`

**Core patterns:**
```typescript
// 1. Service (extends BaseService)
export class EntityService extends BaseService<EntityPublic, CreateRequest, UpdateRequest> {
  protected readonly tableName = "entities";
  protected readonly publicSchema = z.object({ id: commonSchemas.uuid, name: z.string() });
}

// 2. Handler (no try-catch)
export const getEntitiesHandler = async (c: Context) => {
  const items = await service.findAll();
  return c.json({ data: items }, 200);
};

// 3. Route (middleware in createRoute)
const route = createRoute({
  method: "get", path: "/api/v1/entities",
  middleware: [authMiddleware, requireAdmin] as const, // For protected routes
});
```

---

## 🎯 s03: Campuses API ← **IMPLEMENT NOW**

**Database Ready**: `campuses` table, `foundation_fees` table, `v_campuses_with_programs` view
**Endpoints**: GET /api/v1/campuses (public + foundation fees), POST/PUT/DELETE (admin)
**Key Logic**: Foundation fee calculations, campus discount logic, program availability

**Campus Schema (from DB)**:
```sql
campuses: id, code, name, city, address, phone, email, discount_percentage, is_active
foundation_fees: campus_id, year, standard_fee, discounted_fee
```

**Sample Data Available**: HN(0%), HCM(0%), DN(30%), CT(30%), QN(50%) discount

---

## 📋 Remaining Sessions (Quick Reference)

| Session | Entity | Complexity | Key Features |
|---------|--------|------------|--------------|
| s04 | Tuition | � Complex | Multi-table JOINs, progressive fees |
| s05 | Scholarships | 🟡 Medium | Eligibility checks, seed data ready |
| s06 | Applications | � Complex | Multi-auth, chatbot integration |
| s07 | Documents | 🟡 Medium | File upload/download |
| s08 | AI Search | � Medium | Chatbot foundation |
| s09 | AI Application | 🟡 Medium | AI processing |
| s10 | Analytics | 🔴 Complex | Aggregations, materialized views |

## 🚨 Essential Rules

**Database**: `import { db } from "@config/database"` (Bun SQL) | **Service**: Extend BaseService | **Handler**: No try-catch | **Auth**: `middleware: [authMiddleware, requireAdmin] as const` | **Extract**: `c.req.param()`, `c.req.json()`

## 🧪 Test Commands
```bash
make services-up && make dev  # Start
curl http://localhost:3000/api/v1/[entity]  # Test public
curl -X POST http://localhost:3000/api/v1/[entity] -H "Authorization: Bearer [token]" -H "Content-Type: application/json" -d '{}'  # Test auth
make test && make fix  # Test & lint
```

## 📊 Tech Stack
**Bun** + **Hono** + **PostgreSQL 17** + **JWT Auth** + **OpenAPI/Scalar** + **15-table schema** + **Auto-docs at /docs**
