# Zod Schema Patterns

## Basic Entity
```typescript
import { z } from "zod";

export const itemSchema = z.object({
  id: z.string().uuid(),
  code: z.string().min(1).max(10),
  name: z.string().min(1).max(100),
  name_en: z.string().max(100).optional(),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
});

export const createItemSchema = itemSchema.omit({
  id: true,
  created_at: true,
  updated_at: true,
});

export const updateItemSchema = createItemSchema.partial();
export type Item = z.infer<typeof itemSchema>;
```

## Response Schemas
```typescript
export const itemResponseSchema = z.object({
  data: itemSchema,
});

export const itemListResponseSchema = z.object({
  data: z.array(itemSchema),
});
```

## Request Schemas
```typescript
// Path parameters
export const idParamSchema = z.object({
  id: z.string().uuid(),
});

// Query parameters
export const querySchema = z.object({
  search: z.string().optional(),
  limit: z.string().optional().default("20").transform(Number),
  offset: z.string().optional().default("0").transform(Number),
});
```

## Relationships
```typescript
export const itemWithCategorySchema = itemSchema.extend({
  category_name: z.string(),
  category_code: z.string(),
});
```
