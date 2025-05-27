# s06: Applications API

## 🎯 Applications CRUD + Multi-level Auth

## 🔧 Tasks (50-60 min)

1. **Types** - `src/types/database.ts` (Application + ownership)
2. **Schemas** - `src/schemas/dashboard/applications.ts` (Role-based)
3. **Service** - `src/services/database/applications.service.ts` (Complex JOINs)
4. **Handlers** - `src/handlers/dashboard/applications.handler.ts` (Role checks)
5. **Routes** - `src/routes/dashboard/applications.ts` (Multi-level auth)
6. **Integration** - Update routes

## ✅ Success Criteria
- [ ] POST /api/v1/dashboard/applications - **Public**
- [ ] GET /api/v1/dashboard/applications - **Admin only**
- [ ] GET /api/v1/dashboard/applications/my - **Student only**
- [ ] PUT status updates - **Admin only**
- [ ] Ownership validation works

## 🔐 Multi-level Auth Pattern
```typescript
// Public submission
app.openapi(createApplicationRoute, createApplicationHandler);

// Student routes
app.use("/my", authMiddleware);
app.use("/my", requireRole("student"));

// Admin routes
app.use("*", authMiddleware);
app.use("*", requireRole("admin", "staff"));
```

## 🧪 Test
```bash
# Public submission
curl -X POST http://localhost:3000/api/v1/dashboard/applications \
  -d '{"student_name":"Nguyen Van A","email":"a@student.com","program_id":"xxx"}'

# Student view own
curl http://localhost:3000/api/v1/dashboard/applications/my \
  -b student_cookies.txt
```

## 🚀 Next: s07_documents_api
