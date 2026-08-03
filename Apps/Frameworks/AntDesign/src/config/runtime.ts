export type RuntimeMetadata = {
  baseUrl: string;
  dashboardId: string | null;
  location: URL;
  timezone: string;
};

function getMetaContent(name: string): string | null {
  return document.querySelector(`meta[name="${name}"]`)?.getAttribute('content') ?? null;
}

function normalizeBaseUrl(baseUrl: string | null): string {
  if (!baseUrl || baseUrl === '/') {
    return '';
  }

  return baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
}

export function getRuntimeMetadata(): RuntimeMetadata {
  const location = new URL(window.location.href);
  const dashboardId = window.localStorage.getItem('ud-dashboard') ?? getMetaContent('ud-dashboard');

  return {
    baseUrl: normalizeBaseUrl(getMetaContent('baseurl')),
    dashboardId,
    location,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  };
}
