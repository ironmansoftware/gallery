import * as AntdIcons from '@ant-design/icons';
import { Typography } from 'antd';
import { createElement, useEffect, useState, type ComponentProps, type ComponentType, type CSSProperties, type ElementType, type ReactNode } from 'react';
import { renderDescriptorContent } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type TypographyKind = 'text' | 'title' | 'paragraph' | 'link';
type TypographyTone = ComponentProps<typeof Typography.Text>['type'];
type TypographyTarget = ComponentProps<typeof Typography.Link>['target'];
type EditableTrigger = 'icon' | 'text' | 'both';

type AntdTypographyCopyable = {
  format?: 'text/plain' | 'text/html';
  icon?: DescriptorContent[];
  text?: string;
  tooltips?: false | DescriptorContent[];
};

type AntdTypographyEditable = {
  enterIcon?: DescriptorContent | false;
  icon?: DescriptorContent;
  maxLength?: number;
  text?: string;
  tooltip?: DescriptorContent | false;
  triggerType?: EditableTrigger[];
};

type AntdTypographyEllipsis = {
  defaultExpanded?: boolean;
  expandable?: boolean;
  rows?: number;
  suffix?: string;
  symbol?: DescriptorContent;
  tooltip?: DescriptorContent | false;
};

type AntdTypographyProps = {
  className?: string;
  code?: boolean;
  content?: DescriptorContent;
  copyable?: boolean | AntdTypographyCopyable;
  delete?: boolean;
  disabled?: boolean;
  editable?: boolean | AntdTypographyEditable;
  ellipsis?: boolean | AntdTypographyEllipsis;
  href?: string;
  id?: string;
  italic?: boolean;
  keyboard?: boolean;
  kind?: TypographyKind;
  level?: 1 | 2 | 3 | 4 | 5;
  mark?: boolean;
  onChange?: (data: { value: string }) => void;
  onClick?: (data: { value: unknown }) => void;
  onCopy?: (data: { value: string }) => void;
  onEditCancel?: (data: { value: string }) => void;
  onEditEnd?: (data: { value: string }) => void;
  onEditStart?: (data: { value: string }) => void;
  onExpand?: (data: { expanded: boolean }) => void;
  render?: (component: DescriptorContent) => ReactNode;
  style?: CSSProperties;
  strong?: boolean;
  target?: TypographyTarget;
  text?: string;
  typographyType?: TypographyTone;
  underline?: boolean;
  value?: unknown;
};

function resolveIconOrContent(
  value: DescriptorContent | undefined,
  render?: (component: DescriptorContent) => ReactNode,
): ReactNode | undefined {
  if (typeof value === 'undefined') {
    return undefined;
  }

  if (typeof value === 'string') {
    const iconComponent = AntdIcons[value as keyof typeof AntdIcons];

    if (typeof iconComponent === 'function') {
      return createElement(iconComponent as ComponentType);
    }
  }

  return renderDescriptorContent(value, render);
}

function resolveNodeArray(
  values: DescriptorContent[] | undefined,
  render?: (component: DescriptorContent) => ReactNode,
): ReactNode[] | undefined {
  if (!values || values.length === 0) {
    return undefined;
  }

  return values.map((value, index) => <span key={index}>{resolveIconOrContent(value, render)}</span>);
}

function resolveEditableTriggerType(triggerType?: EditableTrigger[]) {
  if (!triggerType || triggerType.length === 0) {
    return undefined;
  }

  const resolvedTriggerTypes = new Set<'icon' | 'text'>();

  for (const currentTrigger of triggerType) {
    if (currentTrigger === 'both') {
      resolvedTriggerTypes.add('icon');
      resolvedTriggerTypes.add('text');
      continue;
    }

    resolvedTriggerTypes.add(currentTrigger);
  }

  return Array.from(resolvedTriggerTypes);
}

function getTypographyComponent(kind: TypographyKind) {
  switch (kind) {
    case 'title':
      return Typography.Title;
    case 'paragraph':
      return Typography.Paragraph;
    case 'link':
      return Typography.Link;
    default:
      return Typography.Text;
  }
}

export function AntdTypography({
  className,
  code,
  content,
  copyable,
  delete: deleted,
  disabled,
  editable,
  ellipsis,
  href,
  id,
  italic,
  keyboard,
  kind = 'text',
  level,
  mark,
  onChange,
  onClick,
  onCopy,
  onEditCancel,
  onEditEnd,
  onEditStart,
  onExpand,
  render,
  style,
  strong,
  target,
  text,
  typographyType,
  underline,
  value,
}: AntdTypographyProps) {
  const resolvedContent = typeof text !== 'undefined' ? text : renderDescriptorContent(content, render);
  const initialEditableText = typeof text === 'string'
    ? text
    : typeof resolvedContent === 'string'
      ? resolvedContent
      : '';
  const configuredEditableText = typeof editable === 'object' && typeof editable.text === 'string'
    ? editable.text
    : initialEditableText;
  const [editableValue, setEditableValue] = useState(configuredEditableText);

  useEffect(() => {
    setEditableValue(configuredEditableText);
  }, [configuredEditableText]);

  const renderedContent = editable ? editableValue : resolvedContent;
  const resolvedCopyable = (() => {
    if (typeof copyable === 'undefined') {
      return undefined;
    }

    if (typeof copyable === 'boolean') {
      return copyable;
    }

    const tooltips = copyable.tooltips === false
      ? false
      : resolveNodeArray(copyable.tooltips, render);
    const resolvedCopyText = copyable.text ?? (typeof renderedContent === 'string' ? renderedContent : initialEditableText);

    return {
      ...(typeof copyable.format === 'undefined' ? {} : { format: copyable.format }),
      ...(typeof copyable.icon === 'undefined' ? {} : { icon: resolveNodeArray(copyable.icon, render) }),
      ...(typeof resolvedCopyText === 'undefined' ? {} : { text: resolvedCopyText }),
      ...(typeof tooltips === 'undefined' ? {} : { tooltips }),
      ...(typeof onCopy === 'undefined'
        ? {}
        : {
            onCopy: () => onCopy({ value: resolvedCopyText ?? '' }),
          }),
    };
  })();
  const resolvedEditable = (() => {
    if (typeof editable === 'undefined') {
      return undefined;
    }

    if (typeof editable === 'boolean') {
      return editable;
    }

    return {
      ...(typeof editable.enterIcon === 'undefined'
        ? {}
        : { enterIcon: editable.enterIcon === false ? null : resolveIconOrContent(editable.enterIcon, render) }),
      ...(typeof editable.icon === 'undefined' ? {} : { icon: resolveIconOrContent(editable.icon, render) }),
      ...(typeof editable.maxLength === 'undefined' ? {} : { maxLength: editable.maxLength }),
      ...(typeof editable.tooltip === 'undefined'
        ? {}
        : { tooltip: editable.tooltip === false ? false : resolveIconOrContent(editable.tooltip, render) }),
      ...(typeof editable.text === 'undefined' ? {} : { text: editableValue }),
      ...(typeof editable.triggerType === 'undefined'
        ? {}
        : { triggerType: resolveEditableTriggerType(editable.triggerType) }),
      onCancel: () => onEditCancel?.({ value: editableValue }),
      onChange: (nextValue: string) => {
        setEditableValue(nextValue);
        onChange?.({ value: nextValue });
      },
      onEnd: () => onEditEnd?.({ value: editableValue }),
      onStart: () => onEditStart?.({ value: editableValue }),
    };
  })();
  const resolvedEllipsis = (() => {
    if (typeof ellipsis === 'undefined') {
      return undefined;
    }

    if (typeof ellipsis === 'boolean') {
      return ellipsis;
    }

    return {
      ...(typeof ellipsis.defaultExpanded === 'undefined' ? {} : { defaultExpanded: ellipsis.defaultExpanded }),
      ...(typeof ellipsis.expandable === 'undefined' ? {} : { expandable: ellipsis.expandable }),
      ...(typeof ellipsis.rows === 'undefined' ? {} : { rows: ellipsis.rows }),
      ...(typeof ellipsis.suffix === 'undefined' ? {} : { suffix: ellipsis.suffix }),
      ...(typeof ellipsis.symbol === 'undefined' ? {} : { symbol: resolveIconOrContent(ellipsis.symbol, render) }),
      ...(typeof ellipsis.tooltip === 'undefined'
        ? {}
        : { tooltip: ellipsis.tooltip === false ? false : resolveIconOrContent(ellipsis.tooltip, render) }),
      ...(typeof onExpand === 'undefined'
        ? {}
        : {
            onExpand: (_event: MouseEvent, info: { expanded: boolean }) => onExpand({ expanded: info.expanded }),
          }),
    };
  })();

  const typographyProps: Record<string, unknown> = {
    ...(typeof className === 'undefined' ? {} : { className }),
    ...(typeof code === 'undefined' ? {} : { code }),
    ...(typeof deleted === 'undefined' ? {} : { delete: deleted }),
    ...(typeof disabled === 'undefined' ? {} : { disabled }),
    ...(typeof id === 'undefined' ? {} : { id }),
    ...(typeof italic === 'undefined' ? {} : { italic }),
    ...(typeof keyboard === 'undefined' ? {} : { keyboard }),
    ...(typeof mark === 'undefined' ? {} : { mark }),
    ...(typeof style === 'undefined' ? {} : { style }),
    ...(typeof strong === 'undefined' ? {} : { strong }),
    ...(typeof typographyType === 'undefined' ? {} : { type: typographyType }),
    ...(typeof underline === 'undefined' ? {} : { underline }),
    ...(typeof resolvedCopyable === 'undefined' ? {} : { copyable: resolvedCopyable }),
    ...(typeof resolvedEditable === 'undefined' ? {} : { editable: resolvedEditable }),
    ...(typeof resolvedEllipsis === 'undefined' ? {} : { ellipsis: resolvedEllipsis }),
    ...(typeof onClick === 'undefined' ? {} : { onClick: () => onClick({ value }) }),
  };

  if (kind === 'title' && typeof level !== 'undefined') {
    typographyProps.level = level;
  }

  if (kind === 'link') {
    if (typeof href !== 'undefined') {
      typographyProps.href = href;
    }

    if (typeof target !== 'undefined') {
      typographyProps.target = target;
    }
  }

  return createElement(getTypographyComponent(kind) as ElementType, typographyProps, renderedContent);
}