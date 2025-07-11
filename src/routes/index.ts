import type { OpenAPIHono } from "@hono/zod-openapi";
import authRoutes from "@routes/auth/auth";
import campusesRoutes from "@routes/campuses";
import departmentsRoutes from "@routes/departments";
import docsRoutes from "@routes/docs";
import healthRoutes from "@routes/health";
import programsRoutes from "@routes/programs";

/**
 * Aggregate all API routes
 */
export function setupRoutes(app: OpenAPIHono) {
  // Documentation routes (/, /docs, /info, /openapi.json)
  app.route("/", docsRoutes);

  // Health check routes
  app.route("/", healthRoutes);

  // Authentication routes
  app.route("/", authRoutes);

  // Departments routes
  app.route("/", departmentsRoutes);

  // Programs routes
  app.route("/", programsRoutes);

  // Campuses routes
  app.route("/", campusesRoutes);

  return app;
}
