# Hono API Patterns

## Imports
```typescript
import { OpenAPIHono, createRoute } from "@hono/zod-openapi";
import { getLogger } from "@middleware/requestLogger";
import { NotFoundError } from "@app-types/errors";
import type { Context } from "hono";
```

## Route Definition
```typescript
const getItemsRoute = createRoute({
  method: "get",
  path: "/",
  tags: ["Items"],
  summary: "Get all items",
  responses: {
    200: {
      content: { "application/json": { schema: itemListResponseSchema } },
      description: "List of items",
    },
  },
});
```

## Handler Pattern (No try-catch)
```typescript
const service = new ItemsService();

export const getItemsHandler = async (c: Context) => {
  const logger = getLogger(c);
  const items = await service.findAll();
  logger.info({ count: items.length }, "Items retrieved");
  return c.json({ data: items }, 200);
};

export const getItemHandler = async (c: Context) => {
  const { id } = c.req.valid("param");
  const item = await service.findById(id);
  if (!item) throw new NotFoundError("Item not found");
  return c.json({ data: item }, 200);
};

export const createItemHandler = async (c: Context) => {
  const data = c.req.valid("json");
  const item = await service.create(data);
  return c.json({ data: item }, 201);
};
```

## Service Pattern
```typescript
export class ItemsService {
  async findAll(): Promise<Item[]> {
    return db`SELECT * FROM items WHERE is_active = true ORDER BY name`;
  }

  async findById(id: string): Promise<Item | null> {
    const [item] = await db`SELECT * FROM items WHERE id = ${id}`;
    return item || null;
  }

  async create(data: CreateItemData): Promise<Item> {
    const [item] = await db`
      INSERT INTO items (name, description)
      VALUES (${data.name}, ${data.description || null})
      RETURNING *
    `;
    return item;
  }

  async update(id: string, data: UpdateItemData): Promise<Item> {
    const [item] = await db`
      UPDATE items SET name = COALESCE(${data.name}, name)
      WHERE id = ${id} RETURNING *
    `;
    return item;
  }
}
```

## Route Registration
```typescript
const app = new OpenAPIHono();
app.route("/departments", departmentsRoutes);
export default app;
```
