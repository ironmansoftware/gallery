import { test, expect } from './harnessFixture';

test('renders the button component documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Button' }).click();

  await expect(page).toHaveURL(/#\/components\/button/);
  await expect(page.getByRole('heading', { name: 'Button' })).toBeVisible();
  await expect(
    page.getByText(
      'Creates an antd-button descriptor that maps the PowerShell command surface to the core Ant Design Button TypeScript definition used by the client runtime. The command mirrors the Ant Design Button API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs.',
    ),
  ).toBeVisible();
  await expect(page.getByText('When To Use', { exact: true })).toBeVisible();
  await expect(page.getByText('A button represents an operation or a short sequence of operations.')).toBeVisible();
  await expect(page.getByText('Use a primary button for the main action in a section, and keep it to one primary action when possible.')).toBeVisible();
  await expect(page.getByText('Syntactic sugar', { exact: true })).toBeVisible();
  await expect(page.getByText('Color and variant', { exact: true })).toBeVisible();
  await expect(page.getByText("New-UDAntDesignButton -Text 'Primary Button' -Type primary")).toBeVisible();
  await expect(page.getByText("New-UDAntDesignButton -Text 'Primary Solid' -Color primary -Variant solid")).toBeVisible();
});

test('shows live previews for the documented button examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Button' }).click();

  await expect(page.getByRole('button', { name: 'Primary Button' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Search End' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Delete Record' })).toHaveClass(/ant-btn-dangerous/);
  await expect(page.getByRole('button', { name: 'Full Width Primary' })).toHaveClass(/ant-btn-block/);
  await expect(page.getByRole('link', { name: 'Link Button' })).toHaveAttribute(
    'href',
    'https://ant.design/components/button/',
  );
  await expect(page.getByRole('button', { name: 'Saving Changes' }).locator('.ant-btn-loading-icon')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Ghost Primary' })).toHaveClass(/ant-btn-background-ghost/);
});