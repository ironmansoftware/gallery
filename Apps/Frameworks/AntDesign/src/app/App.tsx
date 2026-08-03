import { Alert, App as AntdApp, ConfigProvider, Layout, Segmented, Spin, Typography, theme } from 'antd';
import { ErrorBoundary } from 'react-error-boundary';
import { useEffect, useMemo, useState } from 'react';
import {
  applyResolvedColorMode,
  getColorModeMediaQuery,
  persistColorModePreference,
  readStoredColorModePreference,
  readSystemColorMode,
  resolveColorMode,
  type ColorModePreference,
  type ResolvedColorMode,
} from '../config/colorMode';
import { useBootstrap } from '../features/bootstrap/useBootstrap';
import { useDashboardConnection } from '../features/transport/useDashboardConnection';
import { renderDescriptorNode } from '../registry/renderDescriptor';
import { useRuntimeStore } from '../state/runtimeStore';

type BootstrapStatusProps = {
  colorModePreference: ColorModePreference;
  onColorModePreferenceChange: (value: ColorModePreference) => void;
  resolvedColorMode: ResolvedColorMode;
};

function useColorModePreference() {
  const [colorModePreference, setColorModePreference] = useState<ColorModePreference>(() =>
    readStoredColorModePreference(),
  );
  const [systemColorMode, setSystemColorMode] = useState<ResolvedColorMode>(() => readSystemColorMode());

  useEffect(() => {
    const mediaQueryList = window.matchMedia(getColorModeMediaQuery());
    const legacyMediaQueryList = mediaQueryList as MediaQueryList & {
      addListener?: (listener: () => void) => void;
      removeListener?: (listener: () => void) => void;
    };
    const updateSystemColorMode = () => {
      setSystemColorMode(mediaQueryList.matches ? 'dark' : 'light');
    };

    updateSystemColorMode();

    if ('addEventListener' in mediaQueryList) {
      mediaQueryList.addEventListener('change', updateSystemColorMode);
      return () => mediaQueryList.removeEventListener('change', updateSystemColorMode);
    }

    legacyMediaQueryList.addListener?.(updateSystemColorMode);
    return () => legacyMediaQueryList.removeListener?.(updateSystemColorMode);
  }, []);

  const resolvedColorMode = resolveColorMode(colorModePreference, systemColorMode);

  useEffect(() => {
    persistColorModePreference(colorModePreference);
  }, [colorModePreference]);

  useEffect(() => {
    applyResolvedColorMode(resolvedColorMode);
  }, [resolvedColorMode]);

  return {
    colorModePreference,
    resolvedColorMode,
    setColorModePreference,
  };
}

function BootstrapStatus({
  colorModePreference,
  onColorModePreferenceChange,
  resolvedColorMode,
}: BootstrapStatusProps) {
  const bootstrapQuery = useBootstrap();
  const setBootstrap = useRuntimeStore((state) => state.setBootstrap);
  const descriptorTree = useRuntimeStore((state) => state.descriptorTree);
  const connectionStatus = useRuntimeStore((state) => state.connectionStatus);
  const transportError = useRuntimeStore((state) => state.transportError);

  useEffect(() => {
    if (bootstrapQuery.data) {
      setBootstrap(bootstrapQuery.data);
    }
  }, [bootstrapQuery.data, setBootstrap]);

  useDashboardConnection();

  if (bootstrapQuery.isLoading) {
    return (
      <div className="shell-state">
        <Spin size="large" />
        <Typography.Text>Bootstrapping dashboard contract...</Typography.Text>
      </div>
    );
  }

  if (bootstrapQuery.error) {
    return (
      <Alert
        type="error"
        message="Bootstrap failed"
        description={bootstrapQuery.error.message}
        showIcon
      />
    );
  }

  if (!descriptorTree) {
    return (
      <Alert
        type="warning"
        message="No descriptor tree"
        description="The bootstrap response completed but did not include a dashboard descriptor."
        showIcon
      />
    );
  }

  return (
    <Layout className="shell-layout">
      <Layout.Header className="shell-header">
        <div className="shell-header-copy">
          <Typography.Title level={3}>PSU Ant Design Framework</Typography.Title>
          <Typography.Paragraph>
            Connection state: <strong>{connectionStatus}</strong>
          </Typography.Paragraph>
        </div>
        <div className="shell-header-actions">
          <div className="shell-theme-control">
            <Typography.Text strong>Theme</Typography.Text>
            <Segmented
              block
              options={[
                { label: 'System', value: 'system' },
                { label: 'Light', value: 'light' },
                { label: 'Dark', value: 'dark' },
              ]}
              value={colorModePreference}
              onChange={(value) => onColorModePreferenceChange(value as ColorModePreference)}
            />
            <Typography.Text type="secondary" className="shell-theme-caption">
              {colorModePreference === 'system'
                ? `Following system (${resolvedColorMode})`
                : `Pinned to ${resolvedColorMode} mode`}
            </Typography.Text>
          </div>
          {transportError ? <Alert type="warning" message={transportError} banner /> : null}
        </div>
      </Layout.Header>
      <Layout.Content className="shell-content">{renderDescriptorNode(descriptorTree)}</Layout.Content>
    </Layout>
  );
}

function ErrorFallback({ error }: { error: Error }) {
  return <Alert type="error" message="Framework render failed" description={error.message} showIcon />;
}

export function App() {
  const { colorModePreference, resolvedColorMode, setColorModePreference } = useColorModePreference();
  const themeConfig = useMemo(
    () => ({
      algorithm: resolvedColorMode === 'dark' ? theme.darkAlgorithm : theme.defaultAlgorithm,
      cssVar: true,
    }),
    [resolvedColorMode],
  );

  return (
    <ConfigProvider theme={themeConfig}>
      <AntdApp>
        <ErrorBoundary FallbackComponent={ErrorFallback}>
          <BootstrapStatus
            colorModePreference={colorModePreference}
            onColorModePreferenceChange={setColorModePreference}
            resolvedColorMode={resolvedColorMode}
          />
        </ErrorBoundary>
      </AntdApp>
    </ConfigProvider>
  );
}
