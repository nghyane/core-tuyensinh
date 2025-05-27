# s00: Authentication API

## 🎯 JWT Authentication + Role-based Auth

## 🔧 Tasks (40-50 min)

1. **Config** - `src/config/auth.ts` + `.env`
2. **Types** - `src/types/auth.ts`
3. **Utils** - `src/utils/password.ts` (Bun hashing)
4. **Service** - `src/services/auth/auth.service.ts`
5. **Middleware** - `src/middleware/auth.ts`
6. **Schemas** - `src/schemas/auth/auth.ts`
7. **Handlers** - `src/handlers/auth/auth.handler.ts`
8. **Routes** - `src/routes/auth/auth.ts`
9. **Integration** - Update routes/index.ts

## ✅ Success Criteria
- [ ] POST /api/v1/auth/register
- [ ] POST /api/v1/auth/login (JWT + cookies)
- [ ] POST /api/v1/auth/logout
- [ ] POST /api/v1/auth/refresh
- [ ] GET /api/v1/auth/profile
- [ ] Role-based middleware ready

## 🧪 Test
```bash
# Register
curl -X POST http://localhost:3000/api/v1/auth/register \
  -d '{"username":"admin","email":"admin@fpt.edu.vn","password":"Admin123456","role":"admin"}'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -d '{"email":"admin@fpt.edu.vn","password":"Admin123456"}' \
  -c cookies.txt
```

## 🚀 Next: s01_departments_api
