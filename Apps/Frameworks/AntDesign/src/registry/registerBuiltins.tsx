import { lazy, type ComponentType } from 'react';
import { withComponentFeatures } from 'universal-dashboard';
import { registerComponent, type RegisteredDashboardComponent } from './components';

let isRegistered = false;

type DashboardComponentModule = Record<string, unknown>;

function createLazyComponent(
  loader: () => Promise<{ default: ComponentType<Record<string, unknown>> }>,
): RegisteredDashboardComponent {
  const LazyComponent = lazy(loader);

  return function LazyDashboardComponent(props: Record<string, unknown>) {
    return <LazyComponent {...props} />;
  };
}

function loadWrappedComponent(
  loader: () => Promise<DashboardComponentModule>,
  exportName: string,
): () => Promise<{ default: ComponentType<Record<string, unknown>> }> {
  return async () => {
    const module = await loader();
    const component = module[exportName];

    if (!component) {
      throw new Error(`Missing component export '${exportName}'.`);
    }

    return {
      default: withComponentFeatures(component as RegisteredDashboardComponent) as ComponentType<Record<string, unknown>>,
    };
  };
}

function registerLazyComponent(
  type: string,
  loader: () => Promise<DashboardComponentModule>,
  exportName: string,
) {
  registerComponent(type, createLazyComponent(loadWrappedComponent(loader, exportName)));
}

export function registerBuiltins() {
  if (isRegistered) {
    return;
  }

  registerLazyComponent('antd-button', () => import('../components/AntdButton'), 'AntdButton');
  registerLazyComponent('antd-checkbox', () => import('../components/AntdCheckbox'), 'AntdCheckbox');
  registerLazyComponent('antd-col', () => import('../components/AntdCol'), 'AntdCol');
  registerLazyComponent('antd-docs', () => import('../components/AntdDocs'), 'AntdDocs');
  registerLazyComponent('antd-input', () => import('../components/AntdInput'), 'AntdInput');
  registerLazyComponent('antd-layout', () => import('../components/AntdLayout'), 'AntdLayout');
  registerLazyComponent('antd-layout-content', () => import('../components/AntdLayout'), 'AntdLayoutContent');
  registerLazyComponent('antd-layout-footer', () => import('../components/AntdLayout'), 'AntdLayoutFooter');
  registerLazyComponent('antd-layout-header', () => import('../components/AntdLayout'), 'AntdLayoutHeader');
  registerLazyComponent('antd-layout-sider', () => import('../components/AntdLayout'), 'AntdLayoutSider');
  registerLazyComponent('antd-rate', () => import('../components/AntdRate'), 'AntdRate');
  registerLazyComponent('antd-row', () => import('../components/AntdRow'), 'AntdRow');
  registerLazyComponent('antd-switch', () => import('../components/AntdSwitch'), 'AntdSwitch');
  registerLazyComponent('antd-text', () => import('../components/AntdText'), 'AntdText');
  registerLazyComponent('antd-typography', () => import('../components/AntdTypography'), 'AntdTypography');
  isRegistered = true;
}
