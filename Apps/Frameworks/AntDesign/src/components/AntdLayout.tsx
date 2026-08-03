import { Layout } from 'antd';
import type { CSSProperties, ComponentProps, ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdBaseLayoutProps = {
  className?: string;
  content?: DescriptorContent;
  dataAttributes?: Record<string, unknown>;
  id?: string;
  render?: (component: DescriptorContent) => ReactNode;
  style?: CSSProperties;
};

type AntdLayoutProps = AntdBaseLayoutProps & {
  hasSider?: boolean;
};

type AntdLayoutSiderProps = AntdBaseLayoutProps & {
  breakpoint?: ComponentProps<typeof Layout.Sider>['breakpoint'];
  collapsed?: boolean;
  collapsedWidth?: ComponentProps<typeof Layout.Sider>['collapsedWidth'];
  collapsible?: boolean;
  defaultCollapsed?: boolean;
  reverseArrow?: boolean;
  theme?: ComponentProps<typeof Layout.Sider>['theme'];
  trigger?: DescriptorContent;
  width?: ComponentProps<typeof Layout.Sider>['width'];
  zeroWidthTriggerStyle?: CSSProperties;
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

function toBaseProps({
  className,
  dataAttributes,
  id,
  style,
}: {
  className: string | undefined;
  dataAttributes: Record<string, unknown> | undefined;
  id: string | undefined;
  style: CSSProperties | undefined;
}) {
  return {
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof style === 'undefined' ? {} : { style }),
    ...toDataAttributeProps(dataAttributes),
  };
}

export function AntdLayout({ className, content, dataAttributes, hasSider, id, render, style }: AntdLayoutProps) {
  const layoutProps: ComponentProps<typeof Layout> & { id?: string } = {
    ...toBaseProps({ className, dataAttributes, id, style }),
    ...(typeof hasSider === 'undefined' ? {} : { hasSider }),
  };

  return <Layout {...layoutProps}>{renderDescriptorContent(content, render)}</Layout>;
}

export function AntdLayoutHeader({ className, content, dataAttributes, id, render, style }: AntdBaseLayoutProps) {
  const headerProps: ComponentProps<typeof Layout.Header> & { id?: string } = {
    ...toBaseProps({ className, dataAttributes, id, style }),
  };

  return <Layout.Header {...headerProps}>{renderDescriptorContent(content, render)}</Layout.Header>;
}

export function AntdLayoutContent({ className, content, dataAttributes, id, render, style }: AntdBaseLayoutProps) {
  const contentProps: ComponentProps<typeof Layout.Content> & { id?: string } = {
    ...toBaseProps({ className, dataAttributes, id, style }),
  };

  return <Layout.Content {...contentProps}>{renderDescriptorContent(content, render)}</Layout.Content>;
}

export function AntdLayoutFooter({ className, content, dataAttributes, id, render, style }: AntdBaseLayoutProps) {
  const footerProps: ComponentProps<typeof Layout.Footer> & { id?: string } = {
    ...toBaseProps({ className, dataAttributes, id, style }),
  };

  return <Layout.Footer {...footerProps}>{renderDescriptorContent(content, render)}</Layout.Footer>;
}

export function AntdLayoutSider({
  breakpoint,
  className,
  collapsed,
  collapsedWidth,
  collapsible,
  content,
  dataAttributes,
  defaultCollapsed,
  id,
  render,
  reverseArrow,
  style,
  theme,
  trigger,
  width,
  zeroWidthTriggerStyle,
}: AntdLayoutSiderProps) {
  const siderProps: ComponentProps<typeof Layout.Sider> & { id?: string } = {
    ...toBaseProps({ className, dataAttributes, id, style }),
    ...(typeof breakpoint === 'undefined' ? {} : { breakpoint }),
    ...(typeof collapsed === 'undefined' ? {} : { collapsed }),
    ...(typeof collapsedWidth === 'undefined' ? {} : { collapsedWidth }),
    ...(typeof collapsible === 'undefined' ? {} : { collapsible }),
    ...(typeof defaultCollapsed === 'undefined' ? {} : { defaultCollapsed }),
    ...(typeof reverseArrow === 'undefined' ? {} : { reverseArrow }),
    ...(typeof theme === 'undefined' ? {} : { theme }),
    ...(typeof trigger === 'undefined' ? {} : { trigger: renderDescriptorContent(trigger, render) }),
    ...(typeof width === 'undefined' ? {} : { width }),
    ...(typeof zeroWidthTriggerStyle === 'undefined' ? {} : { zeroWidthTriggerStyle }),
  };

  return <Layout.Sider {...siderProps}>{renderDescriptorContent(content, render)}</Layout.Sider>;
}