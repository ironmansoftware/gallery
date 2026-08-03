import { Card, Typography } from 'antd';
import type { ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdTextProps = {
  content?: DescriptorContent;
  id?: string;
  render?: (component: DescriptorContent) => ReactNode;
  text?: string;
};

export function AntdText({ content, id, render, text }: AntdTextProps) {
  const resolvedContent = text ?? renderDescriptorContent(content, render);
  const cardProps = typeof id === 'string' ? { id } : {};

  return (
    <Card className="component-card" {...cardProps}>
      <Typography.Paragraph>{resolvedContent}</Typography.Paragraph>
    </Card>
  );
}
