import type { ComponentType } from 'react';

export type RegisteredDashboardComponent = ComponentType<Record<string, unknown>>;

const componentRegistry = new Map<string, RegisteredDashboardComponent>();

export function registerComponent(type: string, component: RegisteredDashboardComponent) {
  componentRegistry.set(type, component);
}

export function getRegisteredComponent(type: string) {
  return componentRegistry.get(type);
}
