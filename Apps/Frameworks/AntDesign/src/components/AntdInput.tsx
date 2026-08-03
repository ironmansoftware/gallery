import * as AntdIcons from '@ant-design/icons';
import { Input as AntdInputControl } from 'antd';
import type { InputProps as AntdInputComponentProps } from 'antd';
import {
  createElement,
  useEffect,
  useState,
  type ChangeEvent,
  type ComponentProps,
  type ComponentType,
  type CSSProperties,
  type KeyboardEvent,
  type ReactNode,
} from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdTextAreaComponentProps = ComponentProps<typeof AntdInputControl.TextArea>;
type AntdSearchComponentProps = ComponentProps<typeof AntdInputControl.Search>;
type AntdPasswordComponentProps = ComponentProps<typeof AntdInputControl.Password>;
type AntdOtpComponentProps = ComponentProps<typeof AntdInputControl.OTP>;

type AntdInputMode = 'input' | 'password' | 'otp' | 'search' | 'textarea';
type AntdInputCountConfig = {
  exceedFormatter?: 'truncate-graphemes';
  max?: number;
  show?: boolean;
  strategy?: 'graphemes';
};
type AntdOtpSeparatorConfig = {
  evenColor?: string;
  oddColor?: string;
  type?: 'alternating-dash';
};

type AntdInputProps = {
  addonAfter?: DescriptorContent;
  addonBefore?: DescriptorContent;
  allowClear?: boolean;
  autoComplete?: string;
  autoFocus?: boolean;
  autoSize?: boolean | { maxRows?: number; minRows?: number };
  className?: string;
  classNames?: Record<string, unknown>;
  count?: AntdInputCountConfig;
  dataAttributes?: Record<string, unknown>;
  defaultValue?: string;
  disabled?: boolean;
  enterButton?: boolean | DescriptorContent;
  id?: string;
  loading?: boolean;
  maxLength?: number;
  mode?: AntdInputMode;
  name?: string;
  onChange?: (data: { value: string }) => void;
  onClear?: (data: { value: string }) => void;
  onInput?: (data: { value: string[] }) => void;
  onPressEnter?: (data: { value: string }) => void;
  onSearch?: (data: { source?: string; value: string }) => void;
  otpFormatter?: 'uppercase';
  otpLength?: number;
  otpMask?: boolean | string;
  otpSeparator?: DescriptorContent | AntdOtpSeparatorConfig;
  passwordVisible?: boolean;
  placeholder?: string;
  prefix?: DescriptorContent;
  render?: (component: DescriptorContent) => ReactNode;
  rows?: number;
  showCount?: boolean;
  size?: AntdInputComponentProps['size'];
  status?: AntdInputComponentProps['status'];
  style?: CSSProperties;
  styles?: Record<string, unknown>;
  suffix?: DescriptorContent;
  type?: string;
  value?: string;
  variant?: AntdInputComponentProps['variant'];
  visibilityToggle?: boolean;
};

function toDataAttributeProps(dataAttributes?: Record<string, unknown>): Record<string, string> {
  if (!dataAttributes) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(dataAttributes).map(([key, currentValue]) => [`data-${key}`, String(currentValue)]),
  );
}

function resolveRenderableContent(
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

function resolveCountConfig(count?: AntdInputCountConfig) {
  if (!count) {
    return undefined;
  }

  return {
    ...(typeof count.max === 'undefined' ? {} : { max: count.max }),
    ...(typeof count.show === 'undefined' ? {} : { show: count.show }),
    ...(count.strategy === 'graphemes'
      ? {
          strategy: (input: string) => Array.from(input).length,
        }
      : {}),
    ...(count.exceedFormatter === 'truncate-graphemes'
      ? {
          exceedFormatter: (input: string, config: { max: number }) => Array.from(input).slice(0, config.max).join(''),
        }
      : {}),
  };
}

function resolveOtpFormatter(formatter?: AntdInputProps['otpFormatter']) {
  if (formatter === 'uppercase') {
    return (value: string) => value.toUpperCase();
  }

  return undefined;
}

function isOtpSeparatorConfig(value: DescriptorContent | AntdOtpSeparatorConfig): value is AntdOtpSeparatorConfig {
  return typeof value === 'object' && value !== null && !Array.isArray(value) && value.type === 'alternating-dash';
}

function resolveOtpSeparator(
  separator: DescriptorContent | AntdOtpSeparatorConfig | undefined,
  render?: (component: DescriptorContent) => ReactNode,
) {
  if (typeof separator === 'undefined') {
    return undefined;
  }

  if (isOtpSeparatorConfig(separator)) {
    const evenColor = separator.evenColor ?? 'red';
    const oddColor = separator.oddColor ?? 'blue';

    return (index: number) => <span style={{ color: index % 2 === 0 ? evenColor : oddColor }}>-</span>;
  }

  return resolveRenderableContent(separator, render);
}

function getEventValue(event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>): string;
function getEventValue(event: KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>): string;
function getEventValue(event: { currentTarget?: { value?: string } }): string {
  return event.currentTarget?.value ?? '';
}

export function AntdInput({
  addonAfter,
  addonBefore,
  allowClear,
  autoComplete,
  autoFocus,
  autoSize,
  className,
  classNames,
  count,
  dataAttributes,
  defaultValue,
  disabled,
  enterButton,
  id,
  loading,
  maxLength,
  mode = 'input',
  name,
  onChange,
  onClear,
  onInput,
  onPressEnter,
  onSearch,
  otpFormatter,
  otpLength,
  otpMask,
  otpSeparator,
  passwordVisible,
  placeholder,
  prefix,
  render,
  rows,
  showCount,
  size,
  status,
  style,
  styles,
  suffix,
  type,
  value,
  variant,
  visibilityToggle,
}: AntdInputProps) {
  const [currentValue, setCurrentValue] = useState<string>(value ?? defaultValue ?? '');
  const [currentPasswordVisible, setCurrentPasswordVisible] = useState<boolean>(passwordVisible ?? false);

  useEffect(() => {
    if (typeof value !== 'undefined') {
      setCurrentValue(value);
      return;
    }

    if (typeof defaultValue !== 'undefined') {
      setCurrentValue(defaultValue);
    }
  }, [defaultValue, value]);

  useEffect(() => {
    if (typeof passwordVisible !== 'undefined') {
      setCurrentPasswordVisible(passwordVisible);
    }
  }, [passwordVisible]);

  const resolvedAddonAfter = resolveRenderableContent(addonAfter, render);
  const resolvedAddonBefore = resolveRenderableContent(addonBefore, render);
  const resolvedEnterButton = typeof enterButton === 'boolean' ? enterButton : resolveRenderableContent(enterButton, render);
  const resolvedPrefix = resolveRenderableContent(prefix, render);
  const resolvedSuffix = resolveRenderableContent(suffix, render);
  const resolvedCount = resolveCountConfig(count);
  const baseProps = {
    ...(typeof autoComplete === 'undefined' ? {} : { autoComplete }),
    ...(typeof autoFocus === 'undefined' ? {} : { autoFocus }),
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof classNames === 'undefined' ? {} : { classNames }),
    ...(typeof disabled === 'undefined' ? {} : { disabled }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof maxLength === 'undefined' ? {} : { maxLength }),
    ...(typeof name === 'undefined' ? {} : { name }),
    ...(typeof placeholder === 'undefined' ? {} : { placeholder }),
    ...(typeof showCount === 'undefined' ? {} : { showCount }),
    ...(typeof size === 'undefined' ? {} : { size }),
    ...(typeof status === 'undefined' ? {} : { status }),
    ...(typeof style === 'undefined' ? {} : { style }),
    ...(typeof styles === 'undefined' ? {} : { styles }),
    ...(typeof variant === 'undefined' ? {} : { variant }),
    ...(typeof resolvedCount === 'undefined' ? {} : { count: resolvedCount }),
    ...toDataAttributeProps(dataAttributes),
  };
  const inputChangeHandlers = {
    onChange: (event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      const nextValue = getEventValue(event);
      setCurrentValue(nextValue);
      onChange?.({ value: nextValue });
    },
    onClear: () => {
      setCurrentValue('');
      onClear?.({ value: '' });
    },
    onPressEnter: (event: KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      onPressEnter?.({ value: getEventValue(event) });
    },
  };

  if (mode === 'textarea') {
    const textAreaProps: AntdTextAreaComponentProps = {
      ...baseProps,
      ...(typeof allowClear === 'undefined' ? {} : { allowClear }),
      ...(typeof autoSize === 'undefined' ? {} : { autoSize }),
      ...(typeof rows === 'undefined' ? {} : { rows }),
      ...inputChangeHandlers,
      value: currentValue,
    };

    return <AntdInputControl.TextArea {...textAreaProps} />;
  }

  if (mode === 'search') {
    const searchProps: AntdSearchComponentProps = {
      ...baseProps,
      ...(typeof allowClear === 'undefined' ? {} : { allowClear }),
      ...(typeof resolvedAddonAfter === 'undefined' ? {} : { addonAfter: resolvedAddonAfter }),
      ...(typeof resolvedAddonBefore === 'undefined' ? {} : { addonBefore: resolvedAddonBefore }),
      ...(typeof resolvedEnterButton === 'undefined' ? {} : { enterButton: resolvedEnterButton }),
      ...(typeof resolvedPrefix === 'undefined' ? {} : { prefix: resolvedPrefix }),
      ...(typeof resolvedSuffix === 'undefined' ? {} : { suffix: resolvedSuffix }),
      ...(typeof loading === 'undefined' ? {} : { loading }),
      ...inputChangeHandlers,
      onSearch: (searchValue, _event, info) => {
        setCurrentValue(searchValue);
        onSearch?.({
          value: searchValue,
          ...(typeof info?.source === 'undefined' ? {} : { source: info.source }),
        });
      },
      value: currentValue,
    };

    return <AntdInputControl.Search {...searchProps} />;
  }

  if (mode === 'password') {
    const passwordProps: AntdPasswordComponentProps = {
      ...baseProps,
      ...(typeof allowClear === 'undefined' ? {} : { allowClear }),
      ...(typeof resolvedPrefix === 'undefined' ? {} : { prefix: resolvedPrefix }),
      ...(typeof resolvedSuffix === 'undefined' ? {} : { suffix: resolvedSuffix }),
      ...inputChangeHandlers,
      ...(typeof visibilityToggle === 'undefined' && typeof passwordVisible === 'undefined'
        ? {}
        : {
            visibilityToggle: typeof passwordVisible === 'undefined'
              ? visibilityToggle
              : {
                  visible: currentPasswordVisible,
                  onVisibleChange: (visible) => {
                    setCurrentPasswordVisible(visible);
                  },
                },
          }),
      value: currentValue,
    };

    return <AntdInputControl.Password {...passwordProps} />;
  }

  if (mode === 'otp') {
    const resolvedFormatter = resolveOtpFormatter(otpFormatter);

    const otpProps: AntdOtpComponentProps = {
      ...(typeof className === 'undefined' ? {} : { className }),
      ...(typeof disabled === 'undefined' ? {} : { disabled }),
      ...(typeof id === 'undefined' ? {} : { id }),
      ...(typeof resolvedFormatter === 'undefined' ? {} : { formatter: resolvedFormatter }),
      ...(typeof otpLength === 'undefined' ? {} : { length: otpLength }),
      ...(typeof otpMask === 'undefined' ? {} : { mask: otpMask }),
      ...(typeof otpSeparator === 'undefined' ? {} : { separator: resolveOtpSeparator(otpSeparator, render) }),
      ...(typeof size === 'undefined' ? {} : { size }),
      ...(typeof status === 'undefined' ? {} : { status }),
      ...(typeof style === 'undefined' ? {} : { style }),
      ...(typeof variant === 'undefined' ? {} : { variant }),
      onChange: (nextValue) => {
        setCurrentValue(nextValue);
        onChange?.({ value: nextValue });
      },
      onInput: (nextValue) => {
        onInput?.({ value: nextValue });
      },
      value: currentValue,
      ...toDataAttributeProps(dataAttributes),
    };

    return <AntdInputControl.OTP {...otpProps} />;
  }

  const inputProps: AntdInputComponentProps = {
    ...baseProps,
    ...(typeof allowClear === 'undefined' ? {} : { allowClear }),
    ...(typeof resolvedAddonAfter === 'undefined' ? {} : { addonAfter: resolvedAddonAfter }),
    ...(typeof resolvedAddonBefore === 'undefined' ? {} : { addonBefore: resolvedAddonBefore }),
    ...(typeof resolvedPrefix === 'undefined' ? {} : { prefix: resolvedPrefix }),
    ...(typeof resolvedSuffix === 'undefined' ? {} : { suffix: resolvedSuffix }),
    ...(typeof type === 'undefined' ? {} : { type }),
    ...inputChangeHandlers,
    value: currentValue,
  };

  return <AntdInputControl {...inputProps} />;
}