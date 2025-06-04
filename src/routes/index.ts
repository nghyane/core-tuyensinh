import type { OpenAPIHono } from "@hono/zod-openapi";
import authRoutes from "@routes/auth/auth";
import docsRoutes from "@routes/docs";
import healthRoutes from "@routes/health";

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

  // Add more route modules here as your API grows
  // Example: app.route('/api/users', userRoutes);
  // Example: app.route('/api/chats', chatRoutes);

  return app;
}
