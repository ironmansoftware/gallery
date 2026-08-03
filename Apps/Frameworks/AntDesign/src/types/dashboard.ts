export type DashboardPrimitive = string | number | boolean | null;

export type DescriptorContent = DashboardPrimitive | DashboardDescriptor | DescriptorContent[];

export type EndpointDescriptor = {
  endpoint?: boolean | undefined;
  name: string;
  javaScript?: string | undefined;
  websocket?: boolean | undefined;
  accept?: string | undefined;
  contentType?: string | undefined;
  [key: string]: unknown;
};

export type DashboardDescriptor = {
  type: string;
  id?: string | undefined;
  content?: DescriptorContent | undefined;
  isPlugin?: boolean | undefined;
  assetId?: string | undefined;
  [key: string]: unknown;
};

export type DashboardBootstrap = {
  dashboard: DescriptorContent;
  sessionId: string;
  pageId: string;
  authType?: string | undefined;
  roles?: string[] | undefined;
  user?: string | undefined;
  idleTimeout?: number | undefined;
  dashboardName?: string | undefined;
  developerLicense?: boolean | undefined;
};
