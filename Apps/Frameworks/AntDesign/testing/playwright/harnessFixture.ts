import { test as base, expect, type APIRequestContext, type Page, type APIResponse } from '@playwright/test';

type HarnessMessageOptions = {
  connectionId?: string;
  dashboardId?: string;
};

type HarnessDownloadRegistration = {
  fileName: string;
  content: string;
  contentType?: string;
};

type HarnessController = {
  baseUrl: string;
  gotoShell: (page: Page) => Promise<void>;
  sendMessage: (messageType: string, data?: unknown, options?: HarnessMessageOptions) => Promise<void>;
  registerDownload: (id: string, download: HarnessDownloadRegistration) => Promise<void>;
};

async function assertOk(requestPromise: Promise<APIResponse>) {
  const response = await requestPromise;
  expect(response.ok()).toBeTruthy();
  return response;
}

function createHarnessController(request: APIRequestContext, baseUrl: string): HarnessController {
  return {
    baseUrl,
    async gotoShell(page: Page) {
      await page.goto(baseUrl, { waitUntil: 'networkidle' });
    },
    async sendMessage(messageType: string, data?: unknown, options?: HarnessMessageOptions) {
      await assertOk(
        request.post(`${baseUrl}/api/harness/messages`, {
          data: {
            messageType,
            data,
            connectionId: options?.connectionId,
            dashboardId: options?.dashboardId,
          },
        }),
      );
    },
    async registerDownload(id: string, download: HarnessDownloadRegistration) {
      await assertOk(
        request.post(`${baseUrl}/api/harness/downloads/${id}`, {
          data: {
            fileName: download.fileName,
            content: download.content,
            contentType: download.contentType ?? 'text/plain',
          },
        }),
      );
    },
  };
}

export const test = base.extend<{ harness: HarnessController }>({
  harness: async ({ request, baseURL }, use) => {
    const resolvedBaseUrl = baseURL ?? 'http://127.0.0.1:5057';
    await use(createHarnessController(request, resolvedBaseUrl));
  },
});

export { expect };