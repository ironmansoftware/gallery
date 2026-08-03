import { useEffect } from 'react';
import { createDashboardHubConnection } from '../../transport/dashboardTransport';
import { dispatchIncomingHubMessage, setElementEventPublisher } from '../../registry/universalDashboard';
import { useRuntimeStore } from '../../state/runtimeStore';

const incomingHubMessages = [
  'antdesign-message',
  'setState',
  'requestState',
  'addElement',
  'clearElement',
  'removeElement',
  'syncElement',
  'download',
  'redirect',
  'log',
  'write',
] as const;

export function useDashboardConnection() {
  const baseUrl = useRuntimeStore((state) => state.baseUrl);
  const dashboardId = useRuntimeStore((state) => state.dashboardId);
  const pageId = useRuntimeStore((state) => state.pageId);
  const sessionId = useRuntimeStore((state) => state.sessionId);
  const timezone = useRuntimeStore((state) => state.timezone);
  const setConnectionId = useRuntimeStore((state) => state.setConnectionId);
  const setConnectionStatus = useRuntimeStore((state) => state.setConnectionStatus);

  useEffect(() => {
    if (!dashboardId || !pageId || !sessionId) {
      return;
    }

    const connection = createDashboardHubConnection({
      baseUrl,
      dashboardId,
      pageId,
      sessionId,
      timezone,
    });

    setElementEventPublisher(async (payload) => {
      await connection.invoke('event', payload);
    });

    for (const messageType of incomingHubMessages) {
      connection.on(messageType, (payload?: unknown) => {
        dispatchIncomingHubMessage(messageType, payload);
      });
    }

    setConnectionStatus('connecting');
    setConnectionId(null);

    connection.onreconnecting((error) => {
      setConnectionId(null);
      setConnectionStatus('reconnecting', error?.message ?? null);
    });

    connection.onreconnected((connectionId) => {
      setConnectionId(connectionId ?? connection.connectionId ?? null);
      setConnectionStatus('connected');
    });

    connection.onclose((error) => {
      setConnectionId(null);
      setConnectionStatus('disconnected', error?.message ?? null);
    });

    let isDisposed = false;

    void connection.start().then(
      () => {
        if (!isDisposed) {
          setConnectionId(connection.connectionId ?? null);
          setConnectionStatus('connected');
        }
      },
      (error: unknown) => {
        if (!isDisposed) {
          setConnectionId(null);
          const message = error instanceof Error ? error.message : 'SignalR connection failed.';
          setConnectionStatus('disconnected', message);
        }
      },
    );

    return () => {
      isDisposed = true;
      setElementEventPublisher(null);
      setConnectionId(null);
      for (const messageType of incomingHubMessages) {
        connection.off(messageType);
      }
      setConnectionStatus('disconnected');
      void connection.stop();
    };
  }, [baseUrl, dashboardId, pageId, sessionId, setConnectionId, setConnectionStatus, timezone]);
}
