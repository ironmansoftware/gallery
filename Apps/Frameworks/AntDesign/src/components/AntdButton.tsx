import * as AntdIcons from '@ant-design/icons';
import { Button } from 'antd';
import type { ButtonProps as AntdButtonComponentProps } from 'antd';
import { createElement, type ComponentType, type ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdButtonProps = {
  autoInsertSpace?: boolean;
  block?: boolean;
  buttonType?: AntdButtonComponentProps['type'];
  className?: string;
  content?: DescriptorContent;
  color?: AntdButtonComponentProps['color'];
  danger?: boolean;
  dataAttributes?: Record<string, unknown>;
  disabled?: boolean;
  ghost?: boolean;
  href?: string;
  htmlType?: AntdButtonComponentProps['htmlType'];
  id?: string;
  icon?: DescriptorContent;
  iconPosition?: AntdButtonComponentProps['iconPosition'];
  loading?: AntdButtonComponentProps['loading'];
  onClick?: (data: { value: unknown }) => void;
  render?: (component: DescriptorContent) => ReactNode;
  rootClassName?: string;
  shape?: AntdButtonComponentProps['shape'];
  size?: AntdButtonComponentProps['size'];
  text?: string;
  variant?: AntdButtonComponentProps['variant'];
  value?: unknown;
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

function resolveIcon(icon: DescriptorContent | undefined, render?: (component: DescriptorContent) => ReactNode) {
  if (typeof icon === 'undefined') {
    return undefined;
  }

  if (typeof icon === 'string') {
    const iconComponent = AntdIcons[icon as keyof typeof AntdIcons];

    if (typeof iconComponent === 'function') {
      return createElement(iconComponent as ComponentType);
    }
  }

  return renderDescriptorContent(icon, render);
}

function resolveLoading(
  loading: AntdButtonComponentProps['loading'] | undefined,
  render?: (component: DescriptorContent) => ReactNode,
) {
  if (!loading || typeof loading !== 'object' || !('icon' in loading)) {
    return loading;
  }

  return {
    ...loading,
    icon: resolveIcon(loading.icon as DescriptorContent | undefined, render),
  };
}

export function AntdButton({
  autoInsertSpace,
  block,
  buttonType,
  className,
  content,
  color,
  danger,
  dataAttributes,
  disabled,
  ghost,
  href,
  htmlType,
  id,
  icon,
  iconPosition,
  loading,
  onClick,
  render,
  rootClassName,
  shape,
  size,
  text,
  value,
  variant,
}: AntdButtonProps) {
  const buttonContent = typeof text !== 'undefined' ? text : renderDescriptorContent(content, render);
  const resolvedIcon = resolveIcon(icon, render);
  const resolvedLoading = resolveLoading(loading, render);
  const buttonProps: AntdButtonComponentProps & { id?: string } = {
    ...(typeof autoInsertSpace === 'undefined' ? {} : { autoInsertSpace }),
    ...(typeof block === 'undefined' ? {} : { block }),
    ...(typeof buttonType === 'undefined' ? {} : { type: buttonType }),
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof color === 'undefined' ? {} : { color }),
    ...(typeof danger === 'undefined' ? {} : { danger }),
    ...(typeof disabled === 'undefined' ? {} : { disabled }),
    ...(typeof ghost === 'undefined' ? {} : { ghost }),
    ...(typeof href === 'undefined' ? {} : { href }),
    ...(typeof htmlType === 'undefined' ? {} : { htmlType }),
    ...(typeof iconPosition === 'undefined' ? {} : { iconPosition }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof resolvedLoading === 'undefined' ? {} : { loading: resolvedLoading }),
    ...(typeof resolvedIcon === 'undefined' ? {} : { icon: resolvedIcon }),
    ...(typeof rootClassName === 'undefined' ? {} : { rootClassName }),
    ...(typeof shape === 'undefined' ? {} : { shape }),
    ...(typeof size === 'undefined' ? {} : { size }),
    ...(typeof variant === 'undefined' ? {} : { variant }),
    ...(typeof onClick === 'undefined' ? {} : { onClick: () => onClick({ value }) }),
    ...toDataAttributeProps(dataAttributes),
  };

  return (
    <Button {...buttonProps}>
      {buttonContent}
    </Button>
  );
}
