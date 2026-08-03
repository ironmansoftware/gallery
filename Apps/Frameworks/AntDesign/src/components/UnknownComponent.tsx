import { Alert } from 'antd';
import type { DashboardDescriptor } from '../types/dashboard';

export function UnknownComponent({ id, type }: DashboardDescriptor) {
  return (
    <Alert
      type="warning"
      message={`Unsupported component type: ${type}`}
      description={id ? `Descriptor id: ${id}` : 'The descriptor did not include an id.'}
      showIcon
    />
  );
}
