# s01: Departments API

## 🎯 Departments CRUD + Auth Protection

## 🔧 Tasks (35-45 min)

1. **Types** - `src/types/database.ts`
2. **Schemas** - `src/schemas/dashboard/departments.ts`
3. **Service** - `src/services/database/departments.service.ts`
4. **Handlers** - `src/handlers/dashboard/departments.handler.ts`
5. **Routes** - `src/routes/dashboard/departments.ts` (Auth protected)
6. **Integration** - Update routes

## ✅ Success Criteria
- [ ] GET /api/v1/dashboard/departments - **Public**
- [ ] POST/PUT/DELETE - **Admin only**
- [ ] Auth middleware integrated

## 🔐 Auth Pattern
```typescript
// Public read access
app.openapi(getDepartmentsRoute, getDepartmentsHandler);

// Protected admin routes
app.use("*", authMiddleware);
app.use("*", requireRole("admin", "super_admin"));
app.openapi(createDepartmentRoute, createDepartmentHandler);
```

## 🧪 Test
```bash
# Public access
curl http://localhost:3000/api/v1/dashboard/departments

# Admin operations (use cookies from s00)
curl -X POST http://localhost:3000/api/v1/dashboard/departments \
  -d '{"code":"IT","name":"Information Technology"}' \
  -b cookies.txt
```

## 🚀 Next: s02_programs_api
