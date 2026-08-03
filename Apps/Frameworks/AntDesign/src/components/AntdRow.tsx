import { Row } from 'antd';
import type { RowProps as AntdRowComponentProps } from 'antd';
import type { CSSProperties, ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdRowProps = {
  align?: AntdRowComponentProps['align'];
  className?: string;
  content?: DescriptorContent;
  dataAttributes?: Record<string, unknown>;
  gutter?: AntdRowComponentProps['gutter'];
  id?: string;
  justify?: AntdRowComponentProps['justify'];
  render?: (component: DescriptorContent) => ReactNode;
  style?: CSSProperties;
  wrap?: boolean;
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

export function AntdRow({
  align,
  className,
  content,
  dataAttributes,
  gutter,
  id,
  justify,
  render,
  style,
  wrap,
}: AntdRowProps) {
  const rowProps: AntdRowComponentProps & { id?: string } = {
    ...(typeof align === 'undefined' ? {} : { align }),
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof gutter === 'undefined' ? {} : { gutter }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof justify === 'undefined' ? {} : { justify }),
    ...(typeof style === 'undefined' ? {} : { style }),
    ...(typeof wrap === 'undefined' ? {} : { wrap }),
    ...toDataAttributeProps(dataAttributes),
  };

  return <Row {...rowProps}>{renderDescriptorContent(content, render)}</Row>;
}