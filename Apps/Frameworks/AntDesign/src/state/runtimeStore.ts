import { create } from 'zustand';
import type { RuntimeMetadata } from '../config/runtime';
import type { DashboardBootstrap, DescriptorContent } from '../types/dashboard';

export type ConnectionStatus = 'idle' | 'connecting' | 'connected' | 'reconnecting' | 'disconnected';

type RuntimeStore = RuntimeMetadata & {
  connectionId: string | null;
  connectionStatus: ConnectionStatus;
  descriptorTree: DescriptorContent | null;
  componentState: Record<string, Record<string, unknown>>;
  dashboardName: string | null;
  roles: string[];
  sessionId: string | null;
  pageId: string | null;
  transportError: string | null;
  initializeShell: (metadata: RuntimeMetadata) => void;
  setBootstrap: (bootstrap: DashboardBootstrap) => void;
  setConnectionId: (connectionId: string | null) => void;
  setConnectionStatus: (status: ConnectionStatus, error?: string | null) => void;
  setComponentState: (componentId: string, state: Record<string, unknown>) => void;
  getComponentState: (componentId: string) => Record<string, unknown> | null;
};

const initialMetadata: RuntimeMetadata = {
  baseUrl: '',
  dashboardId: null,
  location: new URL('http://localhost'),
  timezone: 'UTC',
};

export const useRuntimeStore = create<RuntimeStore>((set, get) => ({
  ...initialMetadata,
  connectionId: null,
  connectionStatus: 'idle',
  descriptorTree: null,
  componentState: {},
  dashboardName: null,
  roles: [],
  sessionId: null,
  pageId: null,
  transportError: null,
  initializeShell: (metadata) => {
    set(metadata);
  },
  setBootstrap: (bootstrap) => {
    set({
      descriptorTree: bootstrap.dashboard,
      dashboardName: bootstrap.dashboardName ?? null,
      pageId: bootstrap.pageId,
      roles: bootstrap.roles ?? [],
      sessionId: bootstrap.sessionId,
    });
  },
  setConnectionId: (connectionId) => {
    set({ connectionId });
  },
  setConnectionStatus: (status, error = null) => {
    set({
      connectionStatus: status,
      transportError: error,
    });
  },
  setComponentState: (componentId, state) => {
    set((current) => ({
      componentState: {
        ...current.componentState,
        [componentId]: state,
      },
    }));
  },
  getComponentState: (componentId) => {
    return get().componentState[componentId] ?? null;
  },
}));
