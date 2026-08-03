import { test, expect } from './harnessFixture';

test('renders a server-pushed Ant Design message', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await expect(page.getByText(/Connection state:/)).toContainText('connected');

  await harness.sendMessage('antdesign-message', {
    content: 'Ant Design message transport is working.',
    type: 'success',
    duration: 0,
    key: 'transport-check',
  });

  await expect(page.getByText('Ant Design message transport is working.')).toBeVisible();
});

test('renders the Message documentation examples as clickable buttons', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Message' }).click();

  await expect(page.getByRole('button', { name: 'Save Changes' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Start Sync' })).toBeVisible();

  await page.getByRole('button', { name: 'Save Changes' }).click();
  await expect(page.getByText('Saved changes.')).toBeVisible();
});