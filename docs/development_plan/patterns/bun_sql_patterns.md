# Bun SQL Patterns

## Import
```typescript
import { db } from "@config/database";
```

## Basic CRUD
```typescript
// Select
const items = await db`SELECT * FROM table_name WHERE is_active = true`;
const [item] = await db`SELECT * FROM table_name WHERE id = ${id}`;

// Insert
const [newItem] = await db`
  INSERT INTO table_name (field1, field2)
  VALUES (${data.field1}, ${data.field2 || null})
  RETURNING *
`;

// Update
const [updated] = await db`
  UPDATE table_name
  SET field1 = COALESCE(${data.field1}, field1)
  WHERE id = ${id} RETURNING *
`;

// Soft Delete
const [deleted] = await db`
  UPDATE table_name SET is_active = false
  WHERE id = ${id} RETURNING *
`;
```

## Relationships
```typescript
// JOIN Query
const items = await db`
  SELECT a.*, b.name as related_name
  FROM table_a a
  JOIN table_b b ON a.related_id = b.id
  WHERE a.is_active = true
`;

// Foreign Key Check
const [related] = await db`
  SELECT id FROM related_table WHERE id = ${data.related_id}
`;
if (!related) throw new NotFoundError("Related record not found");
```

## Search & Filter
```typescript
// Text Search
const results = await db`
  SELECT * FROM table_name
  WHERE is_active = true
    AND (${search} IS NULL OR name ILIKE ${'%' + search + '%'})
`;

// Multiple Filters + Pagination
const filtered = await db`
  SELECT * FROM table_name
  WHERE is_active = true
    AND (${categoryId} IS NULL OR category_id = ${categoryId})
  LIMIT ${limit} OFFSET ${offset}
`;
```
