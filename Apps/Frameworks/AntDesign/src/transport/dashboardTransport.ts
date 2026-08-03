import { HubConnection, HubConnectionBuilder, LogLevel } from '@microsoft/signalr';
import { parseDashboardBootstrap } from '../schema/dashboard';
import type { DashboardBootstrap, EndpointDescriptor } from '../types/dashboard';
import { useRuntimeStore } from '../state/runtimeStore';

type ConnectionInput = {
  baseUrl: string;
  dashboardId: string;
  pageId: string;
  sessionId: string;
  timezone: string;
};

type EndpointOptions = {
  query?: Record<string, string>;
};

function buildUrl(baseUrl: string, path: string): string {
  return `${baseUrl}${path}`;
}

function createRequestBody(body: unknown, contentType?: string): BodyInit | undefined {
  if (typeof body === 'undefined' || body === null) {
    return undefined;
  }

  if (body instanceof FormData) {
    return body;
  }

  if (typeof body === 'string') {
    return body;
  }

  if (contentType === 'text/plain') {
    return String(body);
  }

  return JSON.stringify(body);
}

export async function fetchDashboardBootstrap(baseUrl: string): Promise<DashboardBootstrap> {
  const response = await fetch(buildUrl(baseUrl, '/api/internal/dashboard'), {
    credentials: 'include',
    headers: {
      Accept: 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error(`Dashboard bootstrap failed with status ${response.status}.`);
  }

  const payload: unknown = await response.json();
  return parseDashboardBootstrap(payload);
}

export function createDashboardHubConnection({
  baseUrl,
  dashboardId,
  pageId,
  sessionId,
  timezone,
}: ConnectionInput): HubConnection {
  const query = new URLSearchParams({
    dashboardid: dashboardId,
    pageid: pageId,
    sessionid: sessionId,
    timezone,
  });

  return new HubConnectionBuilder()
    .withUrl(buildUrl(baseUrl, `/dashboardhub?${query.toString()}`), {
      withCredentials: true,
    })
    .withAutomaticReconnect()
    .configureLogging(LogLevel.Warning)
    .build();
}

export async function invokeComponentEndpoint(
  baseUrl: string,
  endpoint: EndpointDescriptor,
  body?: unknown,
  options?: EndpointOptions,
): Promise<Response> {
  const query = new URLSearchParams(options?.query ?? {});
  const querySuffix = query.size > 0 ? `?${query.toString()}` : '';
  const contentType = body instanceof FormData ? undefined : endpoint.contentType;
  const connectionId = useRuntimeStore.getState().connectionId;
  const requestBody = createRequestBody(body, contentType);
  const requestInit: RequestInit = {
    method: 'POST',
    credentials: 'include',
    headers: {
      Accept: endpoint.accept ?? 'application/json',
      ...(connectionId ? { UDConnectionId: connectionId } : {}),
      ...(contentType ? { 'Content-Type': contentType } : {}),
    },
  };

  if (requestBody !== undefined) {
    requestInit.body = requestBody;
  }

  return fetch(buildUrl(baseUrl, `/api/internal/component/element/${endpoint.name}${querySuffix}`), requestInit);
}

export async function getComponentEndpoint(baseUrl: string, endpointId: string): Promise<Response> {
  return fetch(buildUrl(baseUrl, `/api/internal/component/element/${endpointId}`), {
    method: 'GET',
    credentials: 'include',
  });
}

export function startDashboardDownload(baseUrl: string, dashboardId: string, downloadId: string, fileName?: string) {
  const anchor = document.createElement('a');
  anchor.href = buildUrl(baseUrl, `/api/internal/dashboard/download/${dashboardId}/${downloadId}`);

  if (fileName) {
    anchor.download = fileName;
  }

  document.body.append(anchor);
  anchor.click();
  anchor.remove();
}
