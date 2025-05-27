# Authentication Patterns

## JWT Config
```typescript
// src/config/auth.ts
export const JWT_CONFIG = {
  secret: process.env.JWT_SECRET!,
  cookieName: "auth_token",
};

export interface JWTPayload {
  sub: string;
  email: string;
  role: string;
}
```

## Password Utils
```typescript
// src/utils/password.ts
export class PasswordUtils {
  static async hash(password: string): Promise<string> {
    return await Bun.password.hash(password, { algorithm: "bcrypt", cost: 12 });
  }

  static async verify(password: string, hash: string): Promise<boolean> {
    return await Bun.password.verify(password, hash);
  }

  static validate(password: string): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (password.length < 8) errors.push("Password must be at least 8 characters");
    if (!/[A-Z]/.test(password)) errors.push("Must contain uppercase letter");
    if (!/[a-z]/.test(password)) errors.push("Must contain lowercase letter");
    if (!/\d/.test(password)) errors.push("Must contain number");
    return { valid: errors.length === 0, errors };
  }
}
```

## Auth Service
```typescript
// src/services/auth/auth.service.ts
export class AuthService {
  async login(email: string, password: string) {
    const [user] = await db`
      SELECT id, email, password_hash, role
      FROM users WHERE email = ${email} AND is_active = true
    `;
    if (!user) return null;

    const isValid = await PasswordUtils.verify(password, user.password_hash);
    if (!isValid) return null;

    const payload = { sub: user.id, email: user.email, role: user.role };
    const token = await sign(payload, JWT_CONFIG.secret);

    return { user: { id: user.id, email: user.email, role: user.role }, token };
  }

  async register(data: { username: string; email: string; password: string; role?: string }) {
    const validation = PasswordUtils.validate(data.password);
    if (!validation.valid) throw new HTTPException(400, { message: validation.errors.join(", ") });

    const passwordHash = await PasswordUtils.hash(data.password);
    const [user] = await db`
      INSERT INTO users (username, email, password_hash, role)
      VALUES (${data.username}, ${data.email}, ${passwordHash}, ${data.role || "student"})
      RETURNING id, email, role
    `;
    return user;
  }

  async verifyToken(token: string): Promise<JWTPayload | null> {
    try {
      const payload = await verify(token, JWT_CONFIG.secret) as JWTPayload;
      const [user] = await db`SELECT id FROM users WHERE id = ${payload.sub} AND is_active = true`;
      return user ? payload : null;
    } catch {
      return null;
    }
  }
}
```

## Auth Middleware
```typescript
// src/middleware/auth.ts
const authService = new AuthService();

export const authMiddleware = createMiddleware(async (c, next) => {
  const authHeader = c.req.header("Authorization");
  const token = authHeader?.replace("Bearer ", "") || getCookie(c, JWT_CONFIG.cookieName);

  if (!token) throw new HTTPException(401, { message: "Authentication required" });

  const payload = await authService.verifyToken(token);
  if (!payload) throw new HTTPException(401, { message: "Invalid token" });

  c.set("user", { id: payload.sub, email: payload.email, role: payload.role });
  await next();
});

export const requireRole = (...allowedRoles: string[]) => {
  return createMiddleware(async (c, next) => {
    const user = c.get("user");
    if (!user || !allowedRoles.includes(user.role)) {
      throw new HTTPException(403, { message: "Insufficient permissions" });
    }
    await next();
  });
};

export const optionalAuth = createMiddleware(async (c, next) => {
  const authHeader = c.req.header("Authorization");
  const token = authHeader?.replace("Bearer ", "") || getCookie(c, JWT_CONFIG.cookieName);

  if (token) {
    const payload = await authService.verifyToken(token);
    if (payload) {
      c.set("user", { id: payload.sub, email: payload.email, role: payload.role });
    }
  }
  await next();
});
```

## Auth Handlers
```typescript
// src/handlers/auth/auth.handler.ts
const authService = new AuthService();

export const loginHandler = async (c: Context) => {
  const { email, password } = c.req.valid("json");
  const result = await authService.login(email, password);
  if (!result) throw new HTTPException(401, { message: "Invalid credentials" });

  setCookie(c, JWT_CONFIG.cookieName, result.token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    maxAge: 24 * 60 * 60,
  });

  return c.json({ data: { user: result.user, token: result.token } }, 200);
};

export const registerHandler = async (c: Context) => {
  const data = c.req.valid("json");
  const user = await authService.register(data);
  return c.json({ data: user }, 201);
};

export const logoutHandler = async (c: Context) => {
  deleteCookie(c, JWT_CONFIG.cookieName);
  return c.json({ message: "Logged out successfully" }, 200);
};

export const profileHandler = async (c: Context) => {
  const user = c.get("user");
  return c.json({ data: user }, 200);
};
```

## Usage Pattern
```typescript
// Route protection
app.use("*", authMiddleware);
app.use("*", requireRole("admin", "super_admin"));

// Context type
declare module "hono" {
  interface ContextVariableMap {
    user?: { id: string; email: string; role: string };
  }
}
```
