import 'antd/dist/reset.css';
import './app/app.css';
import * as React from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { App } from './app/App';
import {
  applyResolvedColorMode,
  readStoredColorModePreference,
  readSystemColorMode,
  resolveColorMode,
} from './config/colorMode';
import { getRuntimeMetadata } from './config/runtime';
import { ensureUniversalDashboardGlobal } from './registry/universalDashboard';
import { registerBuiltins } from './registry/registerBuiltins';
import { useRuntimeStore } from './state/runtimeStore';

const queryClient = new QueryClient();

Object.assign(globalThis as Record<string, unknown>, {
  React,
  react: React,
});

ensureUniversalDashboardGlobal();
registerBuiltins();
useRuntimeStore.getState().initializeShell(getRuntimeMetadata());
applyResolvedColorMode(resolveColorMode(readStoredColorModePreference(), readSystemColorMode()));

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <QueryClientProvider client={queryClient}>
    <App />
  </QueryClientProvider>,
);
