/**
 * Tuition service - Business logic for tuition operations
 * Optimized with PostgreSQL views and functions
 */

import type {
  CampusTuitionParams,
  CampusTuitionSummary,
  CreateTuitionRequest,
  TuitionCalculateParams,
  TuitionCalculation,
  TuitionComparison,
  TuitionComparisonParams,
  TuitionQueryParams,
  TuitionSummary,
  UpdateTuitionRequest,
} from "@app-types/tuition";
import { db } from "@config/database";
import {
  campusTuitionSummarySchema,
  createTuitionSchema,
  tuitionCalculationSchema,
  tuitionComparisonSchema,
  tuitionSummarySchema,
  updateTuitionSchema,
} from "@schemas/tuition";
import { z } from "zod";
import { BaseService, type PaginatedResponse } from "./base.service";

export class TuitionService extends BaseService<
  TuitionSummary,
  CreateTuitionRequest,
  UpdateTuitionRequest
> {
  protected readonly tableName = "progressive_tuition";

  /**
   * Zod schemas for validation and transformation
   */
  protected readonly publicSchema = tuitionSummarySchema;
  protected readonly createSchema = createTuitionSchema;
  protected readonly updateSchema = updateTuitionSchema;

  /**
   * Get all tuition fees with filtering and pagination
   * Uses v_tuition_summary view for optimized performance
   */
  async findAll(
    params: TuitionQueryParams = {}
  ): Promise<PaginatedResponse<TuitionSummary>> {
    const {
      program_code,
      campus_code,
      year = 2025,
      limit = 50,
      offset = 0,
    } = params;

    const [dataRows, countRows] = await Promise.all([
      db`
        SELECT * FROM v_tuition_summary 
        WHERE (${program_code}::text IS NULL OR program_code = ${program_code})
          AND (${campus_code}::text IS NULL OR campus_code = ${campus_code})
          AND year = ${year}
        ORDER BY department_name, program_name, campus_name
        LIMIT ${limit} OFFSET ${offset}
      `,
      db`
        SELECT COUNT(*) as total FROM v_tuition_summary 
        WHERE (${program_code}::text IS NULL OR program_code = ${program_code})
          AND (${campus_code}::text IS NULL OR campus_code = ${campus_code})
          AND year = ${year}
      `,
    ]);

    const total = this.extractTotal(countRows);
    const data = this.parseMany(dataRows);

    return this.createPaginatedResponse(data, total, limit, offset);
  }

  /**
   * Get tuition by ID
   * Uses v_tuition_summary view
   */
  async findById(id: string): Promise<TuitionSummary | null> {
    const [tuition] = await db`
      SELECT * FROM v_tuition_summary 
      WHERE id = ${id}
    `;
    return tuition ? this.parseOne(tuition) : null;
  }

  /**
   * Get tuition comparison across campuses
   * Uses v_tuition_comparison view
   */
  async getComparison(
    params: TuitionComparisonParams = {}
  ): Promise<TuitionComparison[]> {
    const { program_code, year = 2025 } = params;

    const rows = await db`
      SELECT * FROM v_tuition_comparison 
      WHERE (${program_code}::text IS NULL OR program_code = ${program_code})
        AND year = ${year}
      ORDER BY department_name, program_name
    `;

    return z.array(tuitionComparisonSchema).parse(rows);
  }

  /**
   * Get campus tuition summary
   * Uses v_campus_tuition_summary view
   */
  async getCampusSummary(
    params: CampusTuitionParams
  ): Promise<CampusTuitionSummary | null> {
    const { campus_code, year = 2025 } = params;

    const [campus] = await db`
      SELECT * FROM v_campus_tuition_summary 
      WHERE campus_code = ${campus_code}
        AND year = ${year}
    `;

    return campus ? campusTuitionSummarySchema.parse(campus) : null;
  }

  /**
   * Calculate total program cost including preparation fees
   * Uses calculate_total_program_cost function
   */
  async calculateTotalCost(
    params: TuitionCalculateParams
  ): Promise<TuitionCalculation | null> {
    const {
      program_code,
      campus_code,
      has_ielts = false,
      year = 2025,
    } = params;

    try {
      const [result] = await db`
        SELECT * FROM calculate_total_program_cost(
          ${program_code}, 
          ${campus_code}, 
          ${year}, 
          ${has_ielts}
        )
      `;

      return result ? tuitionCalculationSchema.parse(result) : null;
    } catch (error) {
      // Handle case where program or campus not found
      return null;
    }
  }

  /**
   * Get tuition with custom filters
   * Uses get_tuition_with_filters function for complex queries
   */
  async findWithFilters(
    programCodes?: string[],
    campusCodes?: string[],
    year = 2025,
    includeInactive = false
  ): Promise<TuitionSummary[]> {
    const rows = await db`
      SELECT * FROM get_tuition_with_filters(
        ${programCodes || null}, 
        ${campusCodes || null}, 
        ${year}, 
        ${includeInactive}
      )
    `;

    // Transform function result to match TuitionSummary interface
    return rows.map((row: any) => ({
      id: row.id || "",
      year,
      program_id: "",
      program_code: row.program_code,
      program_name: row.program_name,
      program_name_en: undefined,
      department_id: "",
      department_code: "",
      department_name: "",
      department_name_en: undefined,
      campus_id: "",
      campus_code: row.campus_code,
      campus_name: row.campus_name,
      campus_city: "",
      campus_discount: row.effective_discount,
      semester_group_1_3_fee: row.semester_1_3_fee,
      semester_group_4_6_fee: row.semester_4_6_fee,
      semester_group_7_9_fee: row.semester_7_9_fee,
      total_program_fee: row.total_program_fee,
      min_semester_fee: row.semester_1_3_fee,
      max_semester_fee: row.semester_7_9_fee,
    }));
  }

  /**
   * Create new tuition record using validation function
   */
  async create(data: CreateTuitionRequest): Promise<TuitionSummary> {
    const [tuition] = await db`
        SELECT * FROM create_tuition_with_validation(
          ${data.program_id},
          ${data.campus_id},
          ${data.year},
          ${data.semester_group_1_3_fee},
          ${data.semester_group_4_6_fee},
          ${data.semester_group_7_9_fee}
        )
      `;

    return this.parseOne(tuition);
  }

  /**
   * Update tuition record using validation function
   */
  async update(
    id: string,
    data: UpdateTuitionRequest
  ): Promise<TuitionSummary> {
    const [tuition] = await db`
      SELECT * FROM update_tuition_with_validation(
        ${id},
        ${data.program_id},
        ${data.campus_id},
        ${data.year},
        ${data.semester_group_1_3_fee},
        ${data.semester_group_4_6_fee},
        ${data.semester_group_7_9_fee},
        ${data.is_active}
      )
    `;

    return this.parseOne(tuition);
  }

  /**
   * Delete tuition record using validation function
   */
  async delete(id: string): Promise<void> {
    await db`
      SELECT delete_tuition_with_validation(${id})
    `;
  }

  /**
   * Check if tuition exists for program and campus
   */
  async existsForProgramAndCampus(
    programId: string,
    campusId: string,
    year: number
  ): Promise<boolean> {
    const [result] = await db`
      SELECT EXISTS(
        SELECT 1 FROM progressive_tuition 
        WHERE program_id = ${programId} 
          AND campus_id = ${campusId} 
          AND year = ${year}
          AND is_active = true
      ) as exists
    `;

    return result.exists;
  }
}
