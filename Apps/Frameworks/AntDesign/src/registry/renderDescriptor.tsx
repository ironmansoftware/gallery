import { Fragment, Suspense, isValidElement, type ReactNode } from 'react';
import { getRegisteredComponent } from './components';
import { UnknownComponent } from '../components/UnknownComponent';
import type { DashboardDescriptor, DescriptorContent, DashboardPrimitive } from '../types/dashboard';

function isDashboardDescriptor(value: DescriptorContent): value is DashboardDescriptor {
  return typeof value === 'object' && value !== null && !Array.isArray(value) && 'type' in value;
}

function renderPrimitive(value: DashboardPrimitive): ReactNode {
  if (value === null) {
    return null;
  }

  return value;
}

export function renderDescriptorContent(
  content: DescriptorContent | undefined,
  render?: (component: DescriptorContent) => ReactNode,
): ReactNode {
  if (typeof content === 'undefined') {
    return null;
  }

  if (render) {
    return render(content);
  }

  return renderDescriptorNode(content);
}

export function renderDescriptorNode(node: DescriptorContent): ReactNode {
  if (Array.isArray(node)) {
    return node.map((item, index) => <Fragment key={index}>{renderDescriptorNode(item)}</Fragment>);
  }

  if (!isDashboardDescriptor(node)) {
    return renderPrimitive(node);
  }

  const Component = getRegisteredComponent(node.type);

  if (!Component) {
    return <UnknownComponent {...node} />;
  }

  return (
    <Suspense fallback={null}>
      <Component key={node.id ?? node.type} {...(node as Record<string, unknown>)} />
    </Suspense>
  );
}

export function renderExistingNode(node: ReactNode): ReactNode {
  return isValidElement(node) ? node : null;
}
