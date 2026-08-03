import { z } from 'zod';
import type { DashboardBootstrap, EndpointDescriptor } from '../types/dashboard';

export const endpointDescriptorSchema = z
  .object({
    name: z.string(),
    javaScript: z.string().optional(),
    websocket: z.boolean().optional(),
    accept: z.string().optional(),
    contentType: z.string().optional(),
  })
  .catchall(z.unknown()) satisfies z.ZodType<EndpointDescriptor>;

export const dashboardDescriptorSchema = z
  .object({
    type: z.string(),
    id: z.string().optional(),
    content: z.unknown().optional(),
    isPlugin: z.boolean().optional(),
    assetId: z.string().optional(),
  })
  .catchall(z.unknown());

export const descriptorContentSchema: z.ZodTypeAny = z.lazy((): z.ZodTypeAny =>
  z.union([
    z.string(),
    z.number(),
    z.boolean(),
    z.null(),
    dashboardDescriptorSchema,
    z.array(descriptorContentSchema),
  ]),
);

export const dashboardBootstrapSchema = z.object({
  dashboard: descriptorContentSchema,
  sessionId: z.string(),
  pageId: z.string(),
  authType: z.string().optional(),
  roles: z.array(z.string()).optional(),
  user: z.string().optional(),
  idleTimeout: z.number().optional(),
  dashboardName: z.string().optional(),
  developerLicense: z.boolean().optional(),
});

export function parseDashboardBootstrap(payload: unknown): DashboardBootstrap {
  return dashboardBootstrapSchema.parse(payload) as DashboardBootstrap;
}
