import { message as antMessage } from 'antd';
import type { ReactNode } from 'react';
import { registerComponent, type RegisteredDashboardComponent } from './components';
import { renderDescriptorNode } from './renderDescriptor';
import { startDashboardDownload } from '../transport/dashboardTransport';
import { useRuntimeStore } from '../state/runtimeStore';

type SubscriptionCallback = (topic: string, payload: Record<string, unknown>) => void;

type ResponseCallback = (payload: unknown) => void;

type RequestHeaders = Record<string, string>;

type UniversalDashboardGlobal = {
  register: (type: string, component: RegisteredDashboardComponent) => void;
  renderComponent: (component: unknown, history?: unknown) => ReactNode;
  subscribe: (topic: string, callback: SubscriptionCallback) => number;
  unsubscribe: (token: number) => void;
  publish: (topic: string, payload: unknown) => void;
  post: (path: string, body: unknown, callback?: ResponseCallback) => Promise<unknown>;
  postWithHeaders: (
    path: string,
    body: unknown,
    callback?: ResponseCallback,
    headers?: RequestHeaders,
  ) => Promise<unknown>;
  get: (path: string, callback?: ResponseCallback) => Promise<unknown>;
};

declare global {
  interface Window {
    UniversalDashboard?: UniversalDashboardGlobal;
  }
}

type Subscription = {
  topic: string;
  callback: SubscriptionCallback;
};

type EventPublisher = (payload: unknown) => Promise<void>;

const subscriptions = new Map<number, Subscription>();
let nextSubscriptionToken = 1;
let publishElementEvent: EventPublisher | null = null;
let globalInitialized = false;

function buildUrl(baseUrl: string, path: string): string {
  return `${baseUrl}${path}`;
}

function createRequestBody(body: unknown, headers?: Headers): BodyInit | undefined {
  if (typeof body === 'undefined' || body === null) {
    return undefined;
  }

  if (body instanceof FormData) {
    return body;
  }

  if (typeof body === 'string') {
    if (headers && !headers.has('Content-Type')) {
      headers.set('Content-Type', 'text/plain');
    }

    return body;
  }

  if (headers && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }

  return JSON.stringify(body);
}

async function parseResponse(response: Response): Promise<unknown> {
  const contentType = response.headers.get('content-type') ?? '';

  if (!response.ok) {
    const errorBody = contentType.includes('application/json')
      ? JSON.stringify(await response.json())
      : await response.text();
    throw new Error(`UniversalDashboard request failed with status ${response.status}: ${errorBody}`);
  }

  if (response.status === 204) {
    return null;
  }

  if (contentType.includes('application/json')) {
    return response.json();
  }

  return response.text();
}

async function request(
  method: 'GET' | 'POST',
  path: string,
  body?: unknown,
  callback?: ResponseCallback,
  headers?: RequestHeaders,
): Promise<unknown> {
  const baseUrl = useRuntimeStore.getState().baseUrl;
  const requestHeaders = new Headers(headers);

  if (
    method === 'POST'
    && path.startsWith('/api/internal/component/element/')
    && !requestHeaders.has('UDConnectionId')
  ) {
    const connectionId = useRuntimeStore.getState().connectionId;
    if (connectionId) {
      requestHeaders.set('UDConnectionId', connectionId);
    }
  }

  const requestBody = method === 'GET' ? undefined : createRequestBody(body, requestHeaders);
  const requestInit: RequestInit = {
    method,
    credentials: 'include',
    headers: requestHeaders,
  };

  if (requestBody !== undefined) {
    requestInit.body = requestBody;
  }

  const response = await fetch(buildUrl(baseUrl, path), requestInit);
  const payload = await parseResponse(response);
  callback?.(payload);
  return payload;
}

function notifySubscribers(topic: string, payload: Record<string, unknown>) {
  for (const subscription of subscriptions.values()) {
    if (subscription.topic === topic) {
      subscription.callback(topic, payload);
    }
  }
}

function resolveTopic(payload: unknown): string | null {
  if (typeof payload === 'string' && payload.length > 0) {
    return payload;
  }

  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    return null;
  }

  const record = payload as Record<string, unknown>;
  const candidate = record.componentId ?? record.id ?? record.elementId ?? record.targetId;
  return typeof candidate === 'string' && candidate.length > 0 ? candidate : null;
}

function normalizePayload(messageType: string, payload: unknown): Record<string, unknown> {
  if (payload && typeof payload === 'object' && !Array.isArray(payload)) {
    return {
      type: messageType,
      ...(payload as Record<string, unknown>),
    };
  }

  return {
    type: messageType,
    value: payload,
  };
}

function handleDownload(payload: unknown) {
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    return;
  }

  const dashboardId = useRuntimeStore.getState().dashboardId;
  if (!dashboardId) {
    return;
  }

  const record = payload as Record<string, unknown>;
  const downloadId = typeof record.id === 'string' ? record.id : null;
  const fileName = typeof record.fileName === 'string' ? record.fileName : undefined;

  if (!downloadId) {
    return;
  }

  startDashboardDownload(useRuntimeStore.getState().baseUrl, dashboardId, downloadId, fileName);
}

function handleRedirect(payload: unknown) {
  const target = typeof payload === 'string'
    ? payload
    : payload && typeof payload === 'object' && !Array.isArray(payload)
      ? (payload as Record<string, unknown>).url ?? (payload as Record<string, unknown>).location
      : null;

  if (typeof target === 'string' && target.length > 0) {
    window.location.assign(target);
  }
}

function handleAntDesignMessage(payload: unknown) {
  if (typeof payload === 'string' && payload.length > 0) {
    void antMessage.info(payload);
    return;
  }

  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    return;
  }

  const record = payload as Record<string, unknown>;
  const content = typeof record.content === 'string'
    ? record.content
    : typeof record.message === 'string'
      ? record.message
      : null;

  if (!content) {
    return;
  }

  const duration = typeof record.duration === 'number' ? record.duration : undefined;
  const key = typeof record.key === 'string' || typeof record.key === 'number' ? record.key : undefined;
  const type = typeof record.type === 'string' ? record.type : 'info';
  const options = {
    content,
    ...(typeof duration === 'number' ? { duration } : {}),
    ...(typeof key !== 'undefined' ? { key } : {}),
  };

  switch (type) {
    case 'success':
      void antMessage.success(options);
      return;
    case 'warning':
      void antMessage.warning(options);
      return;
    case 'error':
      void antMessage.error(options);
      return;
    case 'loading':
      void antMessage.loading(options);
      return;
    default:
      void antMessage.info(options);
      return;
  }
}

export function setElementEventPublisher(publisher: EventPublisher | null) {
  publishElementEvent = publisher;
}

export function dispatchIncomingHubMessage(messageType: string, payload?: unknown) {
  switch (messageType) {
    case 'antdesign-message':
      handleAntDesignMessage(payload);
      return;
    case 'download':
      handleDownload(payload);
      return;
    case 'redirect':
      handleRedirect(payload);
      return;
    case 'write':
    case 'log':
      if (typeof payload !== 'undefined') {
        console.info(`[${messageType}]`, payload);
      }
      return;
    default:
      break;
  }

  const topic = resolveTopic(payload);
  if (!topic) {
    return;
  }

  notifySubscribers(topic, normalizePayload(messageType, payload));
}

export function ensureUniversalDashboardGlobal() {
  if (globalInitialized) {
    return;
  }

  window.UniversalDashboard = {
    register: (type: string, component: RegisteredDashboardComponent) => {
      registerComponent(type, component);
    },
    renderComponent: (component: unknown) => renderDescriptorNode(component as never),
    subscribe: (topic: string, callback: SubscriptionCallback) => {
      const token = nextSubscriptionToken;
      nextSubscriptionToken += 1;
      subscriptions.set(token, { topic, callback });
      return token;
    },
    unsubscribe: (token: number) => {
      subscriptions.delete(token);
    },
    publish: (topic: string, payload: unknown) => {
      if (topic === 'element-event' && publishElementEvent) {
        void publishElementEvent(payload);
      }
    },
    post: (path: string, body: unknown, callback?: ResponseCallback) => request('POST', path, body, callback),
    postWithHeaders: (
      path: string,
      body: unknown,
      callback?: ResponseCallback,
      headers?: RequestHeaders,
    ) => request('POST', path, body, callback, headers),
    get: (path: string, callback?: ResponseCallback) => request('GET', path, undefined, callback),
  };

  globalInitialized = true;
}