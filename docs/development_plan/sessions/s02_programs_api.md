# s02: Programs API

## 🎯 Programs CRUD + Department Relationships + Auth

## 🔧 Tasks (40-50 min)

1. **Types** - `src/types/database.ts` (Program + relationships)
2. **Schemas** - `src/schemas/dashboard/programs.ts` (Query filters)
3. **Service** - `src/services/database/programs.service.ts` (JOINs)
4. **Handlers** - `src/handlers/dashboard/programs.handler.ts` (Pagination)
5. **Routes** - `src/routes/dashboard/programs.ts` (Auth pattern)
6. **Integration** - Update routes

## ✅ Success Criteria
- [ ] GET /api/v1/dashboard/programs (with department info) - **Public**
- [ ] Query filters: department_id, search, pagination
- [ ] POST/PUT/DELETE - **Admin only**
- [ ] Foreign key validation

## 🧪 Test
```bash
# Public filtering
curl "http://localhost:3000/api/v1/dashboard/programs?department_id=xxx&search=computer"

# Admin operations
curl -X POST http://localhost:3000/api/v1/dashboard/programs \
  -d '{"code":"CS","name":"Computer Science","department_id":"xxx"}' \
  -b cookies.txt
```

## 🚀 Next: s03_campuses_api
