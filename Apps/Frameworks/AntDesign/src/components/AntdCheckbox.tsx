import { Checkbox as AntdCheckboxControl } from 'antd';
import type { CheckboxChangeEvent, CheckboxProps as AntdCheckboxComponentProps } from 'antd';
import { useEffect, useState, type CSSProperties, type ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdCheckboxProps = {
  autoFocus?: boolean;
  checked?: boolean;
  className?: string;
  classNames?: Record<string, string>;
  dataAttributes?: Record<string, unknown>;
  defaultChecked?: boolean;
  disabled?: boolean;
  id?: string;
  indeterminate?: boolean;
  label?: DescriptorContent;
  onChange?: (data: { checked: boolean; value: unknown }) => void;
  render?: (component: DescriptorContent) => ReactNode;
  style?: CSSProperties;
  styles?: Record<string, CSSProperties>;
  value?: unknown;
};

type AntdCheckboxRuntimeProps = AntdCheckboxComponentProps & {
  classNames?: Record<string, string>;
  dataAttributes?: Record<string, unknown>;
  id?: string;
  styles?: Record<string, CSSProperties>;
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

export function AntdCheckbox({
  autoFocus,
  checked,
  className,
  classNames,
  dataAttributes,
  defaultChecked,
  disabled,
  id,
  indeterminate,
  label,
  onChange,
  render,
  style,
  styles,
  value,
}: AntdCheckboxProps) {
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

  const checkboxProps: AntdCheckboxRuntimeProps = {
    ...(typeof autoFocus === 'undefined' ? {} : { autoFocus }),
    checked: currentChecked,
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof classNames === 'undefined' ? {} : { classNames }),
    ...(typeof disabled === 'undefined' ? {} : { disabled }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof indeterminate === 'undefined' ? {} : { indeterminate }),
    ...(typeof style === 'undefined' ? {} : { style }),
    ...(typeof styles === 'undefined' ? {} : { styles }),
    ...(typeof value === 'undefined' ? {} : { value }),
    onChange: (event: CheckboxChangeEvent) => {
      const nextChecked = event.target.checked;
      setCurrentChecked(nextChecked);
      onChange?.({ checked: nextChecked, value });
    },
    ...toDataAttributeProps(dataAttributes),
  };

  return <AntdCheckboxControl {...checkboxProps}>{renderDescriptorContent(label, render)}</AntdCheckboxControl>;
}