import * as AntdIcons from '@ant-design/icons';
import { Rate as AntdRateControl } from 'antd';
import type { RateProps as AntdRateComponentProps } from 'antd';
import { createElement, type ComponentType, type CSSProperties, type ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdRateProps = {
  allowClear?: boolean;
  allowHalf?: boolean;
  character?: DescriptorContent;
  className?: string;
  count?: number;
  dataAttributes?: Record<string, unknown>;
  defaultValue?: number;
  disabled?: boolean;
  id?: string;
  keyboard?: boolean;
  onChange?: (data: { value: number }) => void;
  onHoverChange?: (data: { value: number }) => void;
  render?: (component: DescriptorContent) => ReactNode;
  size?: 'small' | 'medium' | 'large';
  style?: CSSProperties;
  tooltips?: string[];
  value?: number;
};

const rateFontSizeBySize: Record<NonNullable<AntdRateProps['size']>, number> = {
  small: 15,
  medium: 20,
  large: 25,
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

function resolveCharacter(
  character: DescriptorContent | undefined,
  render?: (component: DescriptorContent) => ReactNode,
): ReactNode | undefined {
  if (typeof character === 'undefined') {
    return undefined;
  }

  if (typeof character === 'string') {
    const iconComponent = AntdIcons[character as keyof typeof AntdIcons];

    if (iconComponent) {
      return createElement(iconComponent as ComponentType);
    }
  }

  return renderDescriptorContent(character, render);
}

export function AntdRate({
  allowClear,
  allowHalf,
  character,
  className,
  count,
  dataAttributes,
  defaultValue,
  disabled,
  id,
  keyboard,
  onChange,
  onHoverChange,
  render,
  size,
  style,
  tooltips,
  value,
}: AntdRateProps) {
  const resolvedCharacter = resolveCharacter(character, render);
  const resolvedStyle = typeof size === 'undefined' ? style : { fontSize: rateFontSizeBySize[size], ...style };
  const rateProps: AntdRateComponentProps & { id?: string } = {
    ...(typeof allowClear === 'undefined' ? {} : { allowClear }),
    ...(typeof allowHalf === 'undefined' ? {} : { allowHalf }),
    ...(typeof resolvedCharacter === 'undefined' ? {} : { character: resolvedCharacter }),
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof count === 'undefined' ? {} : { count }),
    ...(typeof defaultValue === 'undefined' ? {} : { defaultValue }),
    ...(typeof disabled === 'undefined' ? {} : { disabled }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof keyboard === 'undefined' ? {} : { keyboard }),
    ...(typeof resolvedStyle === 'undefined' ? {} : { style: resolvedStyle }),
    ...(typeof tooltips === 'undefined' ? {} : { tooltips }),
    ...(typeof value === 'undefined' ? {} : { value }),
    ...(typeof onChange === 'undefined' ? {} : { onChange: (nextValue) => onChange({ value: nextValue }) }),
    ...(typeof onHoverChange === 'undefined'
      ? {}
      : { onHoverChange: (nextValue) => onHoverChange({ value: nextValue }) }),
    ...toDataAttributeProps(dataAttributes),
  };

  return <AntdRateControl {...rateProps} />;
}