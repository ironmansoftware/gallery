import { useQuery } from '@tanstack/react-query';
import { fetchDashboardBootstrap } from '../../transport/dashboardTransport';
import { useRuntimeStore } from '../../state/runtimeStore';

export function useBootstrap() {
  const baseUrl = useRuntimeStore((state) => state.baseUrl);

  return useQuery({
    queryKey: ['dashboard-bootstrap', baseUrl],
    queryFn: () => fetchDashboardBootstrap(baseUrl),
    staleTime: Number.POSITIVE_INFINITY,
  });
}
