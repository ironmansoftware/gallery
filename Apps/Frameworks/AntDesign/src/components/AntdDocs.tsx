import { BookOutlined, LinkOutlined } from '@ant-design/icons';
import { Button, Card, Empty, Menu, Space, Table, Tag, Typography } from 'antd';
import type { MenuProps, TableColumnsType } from 'antd';
import { useEffect, useMemo, useState } from 'react';
import { renderDescriptorNode } from '../registry/renderDescriptor';
import type { DescriptorContent } from '../types/dashboard';

type AntdDocsParameter = {
  description?: string;
  name: string;
  required?: boolean;
  type?: string;
  validValues?: string | string[];
};

type AntdDocsExample = {
  code: string;
  description?: string;
  preview?: DescriptorContent;
  title: string;
};

type AntdDocsComponent = {
  category?: string;
  commandName?: string;
  description?: string;
  examples?: AntdDocsExample[];
  key: string;
  parameters?: AntdDocsParameter[];
  sourceUrl?: string;
  summary?: string;
  title: string;
  whenToUse?: string[];
};

type AntdDocsProps = {
  components?: AntdDocsComponent[];
  overview?: string;
  title?: string;
};

const overviewRoute = '/overview';

function getComponentRoute(componentKey: string) {
  return `/components/${componentKey}`;
}

function normalizeRoute(hash: string, components: AntdDocsComponent[]): string {
  const normalizedHash = hash.replace(/^#/, '') || overviewRoute;

  if (normalizedHash === overviewRoute) {
    return overviewRoute;
  }

  const matchingComponent = components.find((component) => getComponentRoute(component.key) === normalizedHash);
  return matchingComponent ? normalizedHash : overviewRoute;
}

function navigate(route: string) {
  window.location.hash = route;
}

function useDocsRoute(components: AntdDocsComponent[]) {
  const [route, setRoute] = useState(() => normalizeRoute(window.location.hash, components));

  useEffect(() => {
    const syncRoute = () => {
      const nextRoute = normalizeRoute(window.location.hash, components);
      setRoute(nextRoute);

      if ((window.location.hash || `#${overviewRoute}`) !== `#${nextRoute}`) {
        window.location.hash = nextRoute;
      }
    };

    syncRoute();
    window.addEventListener('hashchange', syncRoute);

    return () => {
      window.removeEventListener('hashchange', syncRoute);
    };
  }, [components]);

  return route;
}

function ParameterTable({ parameters }: { parameters: AntdDocsParameter[] }) {
  const normalizeValidValues = (validValues?: string | string[]) => {
    if (typeof validValues === 'undefined') {
      return [];
    }

    return Array.isArray(validValues) ? validValues : [validValues];
  };

  const columns: TableColumnsType<AntdDocsParameter> = [
    {
      dataIndex: 'name',
      key: 'name',
      render: (value: string) => <Typography.Text code>{value}</Typography.Text>,
      title: 'Parameter',
      width: 180,
    },
    {
      dataIndex: 'type',
      key: 'type',
      render: (value?: string) => value ?? 'Object',
      title: 'Type',
      width: 140,
    },
    {
      dataIndex: 'required',
      key: 'required',
      render: (value?: boolean) => (value ? <Tag color="red">Required</Tag> : <Tag>Optional</Tag>),
      title: 'Requirement',
      width: 140,
    },
    {
      dataIndex: 'description',
      key: 'description',
      render: (value?: string, record?: AntdDocsParameter) => {
        const validValues = normalizeValidValues(record?.validValues);

        return (
          <Space direction="vertical" size={4}>
            <Typography.Text>{value ?? 'No description available.'}</Typography.Text>
            {validValues.length > 0 ? (
            <Space size={[4, 4]} wrap>
                {validValues.map((validValue) => (
                <Tag key={`${record?.name ?? 'parameter'}-${validValue}`}>{validValue}</Tag>
              ))}
            </Space>
            ) : null}
          </Space>
        );
      },
      title: 'Description',
    },
  ];

  return (
    <Table
      className="docs-parameter-table"
      columns={columns}
      dataSource={parameters.map((parameter) => ({ ...parameter, key: parameter.name }))}
      pagination={false}
      size="middle"
    />
  );
}

function OverviewPage({ components, overview, title }: { components: AntdDocsComponent[]; overview?: string; title?: string }) {
  return (
    <div className="docs-body">
      <Card className="docs-hero" variant="borderless">
        <Space direction="vertical" size={12}>
          <Tag className="docs-kicker" color="blue">
            Generated from comment-based help
          </Tag>
          <Typography.Title level={1}>{title ?? 'Ant Design Components'}</Typography.Title>
          <Typography.Paragraph>
            {overview ??
              'Browse the PowerShell Universal Ant Design framework components. Each component page is built from the command help so examples stay in sync with the docs and the module.'}
          </Typography.Paragraph>
        </Space>
      </Card>

      <div className="docs-overview-grid">
        {components.map((component) => (
          <Card key={component.key} className="docs-overview-card" hoverable>
            <Space direction="vertical" size={12}>
              <Tag>{component.category ?? 'Component'}</Tag>
              <Typography.Title level={3}>{component.title}</Typography.Title>
              <Typography.Paragraph>{component.summary ?? component.description}</Typography.Paragraph>
              <Button type="primary" onClick={() => navigate(getComponentRoute(component.key))}>
                Open {component.title}
              </Button>
            </Space>
          </Card>
        ))}
      </div>
    </div>
  );
}

function ComponentPage({ component }: { component: AntdDocsComponent }) {
  return (
    <div className="docs-body">
      <Card className="docs-hero" variant="borderless">
        <Space direction="vertical" size={12}>
          <Space size={[8, 8]} wrap>
            <Tag color="blue">{component.category ?? 'Component'}</Tag>
            {component.commandName ? <Tag icon={<BookOutlined />}>{component.commandName}</Tag> : null}
          </Space>
          <Typography.Title level={1}>{component.title}</Typography.Title>
          <Typography.Paragraph>{component.description ?? component.summary}</Typography.Paragraph>
          <Space size={[8, 8]} wrap>
            {component.commandName ? <Typography.Text code>{component.commandName}</Typography.Text> : null}
            {component.sourceUrl ? (
              <Button href={component.sourceUrl} icon={<LinkOutlined />} target="_blank">
                Ant Design reference
              </Button>
            ) : null}
          </Space>
        </Space>
      </Card>

      {component.whenToUse && component.whenToUse.length > 0 ? (
        <Card className="docs-section-card" title="When To Use">
          <Space direction="vertical" size={12} style={{ width: '100%' }}>
            {component.whenToUse.map((item) => (
              <Typography.Paragraph key={`${component.key}-${item}`}>{item}</Typography.Paragraph>
            ))}
          </Space>
        </Card>
      ) : null}

      <Space className="docs-example-list" direction="vertical" size={24}>
        {(component.examples ?? []).map((example) => (
          <Card key={`${component.key}-${example.title}`} className="docs-section-card" title={example.title}>
            <Space direction="vertical" size={16} style={{ width: '100%' }}>
              <div className={`docs-preview-surface${component.key === 'button' ? ' docs-preview-surface-button' : ''}`}>
                {typeof example.preview === 'undefined' ? null : renderDescriptorNode(example.preview)}
              </div>
              {example.description ? <Typography.Paragraph>{example.description}</Typography.Paragraph> : null}
              <pre className="docs-code-block">
                <code>{example.code}</code>
              </pre>
            </Space>
          </Card>
        ))}
      </Space>

      <Card className="docs-section-card" title="Parameters">
        {component.parameters && component.parameters.length > 0 ? (
          <ParameterTable parameters={component.parameters} />
        ) : (
          <Empty description="No parameter documentation available." image={Empty.PRESENTED_IMAGE_SIMPLE} />
        )}
      </Card>
    </div>
  );
}

export function AntdDocs({ components = [], overview, title }: AntdDocsProps) {
  const items = useMemo<NonNullable<MenuProps['items']>>(() => {
    return [
      {
        key: overviewRoute,
        label: 'Overview',
      },
      {
        children: components.map((component) => ({
          key: getComponentRoute(component.key),
          label: component.title,
        })),
        key: 'components',
        label: 'Components',
        type: 'group',
      },
    ];
  }, [components]);

  const route = useDocsRoute(components);
  const activeComponent = components.find((component) => getComponentRoute(component.key) === route);

  return (
    <div className="docs-shell">
      <aside className="docs-sidebar">
        <Card className="docs-sidebar-card" variant="borderless">
          <Space direction="vertical" size={8}>
            <Typography.Title level={4}>{title ?? 'Ant Design Docs'}</Typography.Title>
            <Typography.Paragraph>
              Component pages mirror the Ant Design style with framework-specific PowerShell command coverage.
            </Typography.Paragraph>
          </Space>
        </Card>
        <Menu className="docs-menu" mode="inline" selectedKeys={[route]} onClick={({ key }) => navigate(key)} items={items} />
      </aside>
      <section className="docs-main">
        {route === overviewRoute || !activeComponent ? (
          <OverviewPage
            components={components}
            {...(typeof overview === 'undefined' ? {} : { overview })}
            {...(typeof title === 'undefined' ? {} : { title })}
          />
        ) : (
          <ComponentPage component={activeComponent} />
        )}
      </section>
    </div>
  );
}