import { test, expect } from './harnessFixture';

test('loads the Ant Design component docs shell', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await expect(page.getByRole('heading', { name: 'Ant Design Components' }).first()).toBeVisible();
  await expect(page.getByText('Generated from comment-based help')).toBeVisible();
  await expect(page.getByRole('menuitem', { name: 'Button' })).toBeVisible();
  await expect(page.getByText(/Connection state:/)).toContainText('connected');
});