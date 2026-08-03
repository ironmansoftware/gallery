import { defineConfig, devices } from '@playwright/test';
import path from 'node:path';

const harnessUrl = process.env.PSU_HARNESS_URL ?? 'http://127.0.0.1:5057';
const harnessDefinitionPath = path.join(process.cwd(), 'harness.ps1');

export default defineConfig({
  testDir: './testing/playwright',
  fullyParallel: true,
  reporter: 'list',
  use: {
    baseURL: harnessUrl,
    trace: 'on-first-retry',
  },
  webServer: {
    command: 'npm run harness',
    cwd: process.cwd(),
    env: {
      ...process.env,
      Harness__DefinitionPath: harnessDefinitionPath,
    },
    url: harnessUrl,
    reuseExistingServer: true,
    timeout: 180000,
  },
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
      },
    },
  ],
});