import { Col } from 'antd';
import type { ColProps as AntdColComponentProps } from 'antd';
import type { CSSProperties, ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdColProps = {
  className?: string;
  content?: DescriptorContent;
  dataAttributes?: Record<string, unknown>;
  flex?: AntdColComponentProps['flex'];
  id?: string;
  lg?: AntdColComponentProps['lg'];
  md?: AntdColComponentProps['md'];
  offset?: AntdColComponentProps['offset'];
  order?: AntdColComponentProps['order'];
  pull?: AntdColComponentProps['pull'];
  push?: AntdColComponentProps['push'];
  render?: (component: DescriptorContent) => ReactNode;
  sm?: AntdColComponentProps['sm'];
  span?: AntdColComponentProps['span'];
  style?: CSSProperties;
  xl?: AntdColComponentProps['xl'];
  xs?: AntdColComponentProps['xs'];
  xxl?: AntdColComponentProps['xxl'];
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

export function AntdCol({
  className,
  content,
  dataAttributes,
  flex,
  id,
  lg,
  md,
  offset,
  order,
  pull,
  push,
  render,
  sm,
  span,
  style,
  xl,
  xs,
  xxl,
}: AntdColProps) {
  const colProps: AntdColComponentProps & { id?: string } = {
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof flex === 'undefined' ? {} : { flex }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof lg === 'undefined' ? {} : { lg }),
    ...(typeof md === 'undefined' ? {} : { md }),
    ...(typeof offset === 'undefined' ? {} : { offset }),
    ...(typeof order === 'undefined' ? {} : { order }),
    ...(typeof pull === 'undefined' ? {} : { pull }),
    ...(typeof push === 'undefined' ? {} : { push }),
    ...(typeof sm === 'undefined' ? {} : { sm }),
    ...(typeof span === 'undefined' ? {} : { span }),
    ...(typeof style === 'undefined' ? {} : { style }),
    ...(typeof xl === 'undefined' ? {} : { xl }),
    ...(typeof xs === 'undefined' ? {} : { xs }),
    ...(typeof xxl === 'undefined' ? {} : { xxl }),
    ...toDataAttributeProps(dataAttributes),
  };

  return <Col {...colProps}>{renderDescriptorContent(content, render)}</Col>;
}