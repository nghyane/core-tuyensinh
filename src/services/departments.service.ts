/**
 * Department service - Business logic for department operations
 */

import type {
  CreateDepartmentRequest,
  Department,
  DepartmentPublic,
  UpdateDepartmentRequest,
} from "@app-types/departments";
import { db } from "@config/database";
import { HTTPException } from "hono/http-exception";

export class DepartmentsService {
  /**
   * Get all active departments
   */
  async findAll(): Promise<DepartmentPublic[]> {
    const departments = await db`
      SELECT id, code, name, name_en, description
      FROM departments 
      WHERE is_active = true 
      ORDER BY name
    `;
    return departments;
  }

  /**
   * Get department by ID
   */
  async findById(id: string): Promise<DepartmentPublic | null> {
    const [department] = await db`
      SELECT id, code, name, name_en, description
      FROM departments 
      WHERE id = ${id} AND is_active = true
    `;
    return department || null;
  }

  /**
   * Get department by code
   */
  async findByCode(code: string): Promise<Department | null> {
    const [department] = await db`
      SELECT id, code, name, name_en, description, is_active, created_at, updated_at
      FROM departments 
      WHERE code = ${code}
    `;
    return department || null;
  }

  /**
   * Create new department
   */
  async create(data: CreateDepartmentRequest): Promise<DepartmentPublic> {
    // Check if department with same code already exists
    const existing = await this.findByCode(data.code);
    if (existing) {
      throw new HTTPException(409, {
        message: `Department with code '${data.code}' already exists`,
      });
    }

    const [department] = await db`
      INSERT INTO departments (code, name, name_en, description)
      VALUES (${data.code}, ${data.name}, ${data.name_en || null}, ${data.description || null})
      RETURNING id, code, name, name_en, description
    `;

    return department;
  }

  /**
   * Update department by ID
   */
  async update(
    id: string,
    data: UpdateDepartmentRequest
  ): Promise<DepartmentPublic> {
    // Check if department exists
    const existing = await this.findById(id);
    if (!existing) {
      throw new HTTPException(404, {
        message: "Department not found",
      });
    }

    // Check if code is being changed and if new code already exists
    if (data.code && data.code !== existing.code) {
      const codeExists = await this.findByCode(data.code);
      if (codeExists && codeExists.id !== id) {
        throw new HTTPException(409, {
          message: `Department with code '${data.code}' already exists`,
        });
      }
    }

    const [department] = await db`
      UPDATE departments 
      SET 
        code = COALESCE(${data.code}, code),
        name = COALESCE(${data.name}, name),
        name_en = COALESCE(${data.name_en}, name_en),
        description = COALESCE(${data.description}, description),
        is_active = COALESCE(${data.is_active}, is_active),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${id}
      RETURNING id, code, name, name_en, description
    `;

    return department;
  }

  /**
   * Soft delete department by ID
   */
  async delete(id: string): Promise<void> {
    // Check if department exists
    const existing = await this.findById(id);
    if (!existing) {
      throw new HTTPException(404, {
        message: "Department not found",
      });
    }

    await db`
      UPDATE departments 
      SET is_active = false, updated_at = CURRENT_TIMESTAMP
      WHERE id = ${id}
    `;
  }
}
