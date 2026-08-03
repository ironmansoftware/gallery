import * as AntdIcons from '@ant-design/icons';
import { Switch as AntdSwitchControl } from 'antd';
import type { SwitchProps as AntdSwitchComponentProps } from 'antd';
import { createElement, useEffect, useState, type ComponentType, type CSSProperties, type ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdSwitchProps = {
  checked?: boolean;
  checkedChildren?: DescriptorContent;
  className?: string;
  classNames?: Record<string, string>;
  dataAttributes?: Record<string, unknown>;
  defaultChecked?: boolean;
  disabled?: boolean;
  id?: string;
  loading?: boolean;
  onChange?: (data: { checked: boolean; value: unknown }) => void;
  onClick?: (data: { checked: boolean; value: unknown }) => void;
  render?: (component: DescriptorContent) => ReactNode;
  size?: AntdSwitchComponentProps['size'];
  styles?: Record<string, CSSProperties>;
  uncheckedChildren?: DescriptorContent;
  value?: unknown;
};

type AntdSwitchRuntimeProps = AntdSwitchComponentProps & {
  classNames?: Record<string, string>;
  styles?: Record<string, CSSProperties>;
  id?: string;
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

function resolveSwitchContent(
  content: DescriptorContent | undefined,
  render?: (component: DescriptorContent) => ReactNode,
): ReactNode | undefined {
  if (typeof content === 'undefined') {
    return undefined;
  }

  if (typeof content === 'string') {
    const iconComponent = AntdIcons[content as keyof typeof AntdIcons];

    if (iconComponent) {
      return createElement(iconComponent as ComponentType);
    }
  }

  return renderDescriptorContent(content, render);
}

export function AntdSwitch({
  checked,
  checkedChildren,
  className,
  classNames,
  dataAttributes,
  defaultChecked,
  disabled,
  id,
  loading,
  onChange,
  onClick,
  render,
  size,
  styles,
  uncheckedChildren,
  value,
}: AntdSwitchProps) {
  const [currentChecked, setCurrentChecked] = useState<boolean>(checked ?? defaultChecked ?? false);

  useEffect(() => {
    if (typeof checked !== 'undefined') {
      setCurrentChecked(checked);
      return;
    }

    if (typeof defaultChecked !== 'undefined') {
      setCurrentChecked(defaultChecked);
    }
  }, [checked, defaultChecked]);

  const switchProps: AntdSwitchRuntimeProps = {
    checked: currentChecked,
    ...(typeof checkedChildren === 'undefined' ? {} : { checkedChildren: resolveSwitchContent(checkedChildren, render) }),
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof classNames === 'undefined' ? {} : { classNames }),
    ...(typeof disabled === 'undefined' ? {} : { disabled }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof loading === 'undefined' ? {} : { loading }),
    ...(typeof size === 'undefined' ? {} : { size }),
    ...(typeof styles === 'undefined' ? {} : { styles }),
    ...(typeof uncheckedChildren === 'undefined'
      ? {}
      : { unCheckedChildren: resolveSwitchContent(uncheckedChildren, render) }),
    onChange: (nextChecked) => {
      setCurrentChecked(nextChecked);
      onChange?.({ checked: nextChecked, value });
    },
    onClick: (nextChecked) => {
      onClick?.({ checked: nextChecked, value });
    },
    ...toDataAttributeProps(dataAttributes),
  };

  return <AntdSwitchControl {...switchProps} />;
}