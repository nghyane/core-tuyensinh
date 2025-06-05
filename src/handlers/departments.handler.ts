/**
 * Department handlers - Request handlers for department operations
 */

import { DepartmentsService } from "@services/departments.service";
import type { Context } from "hono";

// Create service instance
const departmentsService = new DepartmentsService();

/**
 * Get all departments handler
 */
export const getDepartmentsHandler = async (c: Context) => {
  const departments = await departmentsService.findAll();
  return c.json({ data: departments }, 200);
};

/**
 * Get department by ID handler
 */
export const getDepartmentHandler = async (c: Context) => {
  const id = c.req.param("id");
  const department = await departmentsService.findById(id);

  if (!department) {
    return c.json({ error: "NOT_FOUND", message: "Department not found" }, 404);
  }

  return c.json({ data: department }, 200);
};

/**
 * Create department handler
 */
export const createDepartmentHandler = async (c: Context) => {
  const data = await c.req.json();
  const department = await departmentsService.create(data);
  return c.json({ data: department }, 201);
};

/**
 * Update department handler
 */
export const updateDepartmentHandler = async (c: Context) => {
  const id = c.req.param("id");
  const data = await c.req.json();
  const department = await departmentsService.update(id, data);
  return c.json({ data: department }, 200);
};

/**
 * Delete department handler
 */
export const deleteDepartmentHandler = async (c: Context) => {
  const id = c.req.param("id");
  await departmentsService.delete(id);
  return c.json({ message: "Department deleted successfully" }, 200);
};
