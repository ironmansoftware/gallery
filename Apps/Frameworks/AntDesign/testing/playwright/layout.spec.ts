import { expect, test } from './harnessFixture';

test('renders the layout component documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Layout' }).click();

  await expect(page).toHaveURL(/#\/components\/layout/);
  await expect(page.getByRole('heading', { name: 'Layout' }).first()).toBeVisible();
  await expect(
    page.getByText(
      'Creates an antd-layout descriptor that maps the PowerShell command surface to the Ant Design Layout component used by the client runtime. Use the layout wrapper to compose page chrome with Header, Sider, Content, and Footer regions while keeping the descriptor contract aligned with the upstream Ant Design layout model.',
    ),
  ).toBeVisible();
  await expect(page.getByText('When To Use', { exact: true })).toBeVisible();
  await expect(
    page.getByText('Layout is the outer container for page structure and can contain nested layouts when a page needs both top and side navigation.'),
  ).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Basic structure' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Header and sider' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Collapsible sider' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Responsive sider' })).toBeVisible();
  await expect(page.getByText("New-UDAntDesignLayoutSider -Breakpoint lg -CollapsedWidth 0 -Width 220")).toBeVisible();
});

test('shows live previews for the documented layout examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Layout' }).click();

  const basicCard = page.locator('.docs-section-card').filter({ hasText: 'Basic structure' });
  await expect(basicCard.locator('.ant-layout')).toBeVisible();
  await expect(basicCard.locator('.ant-layout-header')).toBeVisible();
  await expect(basicCard.locator('.ant-layout-content')).toBeVisible();
  await expect(basicCard.locator('.ant-layout-footer')).toBeVisible();
  await expect(basicCard.locator('.ant-layout-header')).toContainText('Header');
  await expect(basicCard.locator('.ant-layout-content')).toContainText('Content');
  await expect(basicCard.locator('.ant-layout-footer')).toContainText('Footer');

  const headerSiderCard = page.locator('.docs-section-card').filter({ hasText: 'Header and sider' });
  await expect(headerSiderCard.locator('.ant-layout-has-sider')).toBeVisible();
  await expect(headerSiderCard.locator('.ant-layout-sider')).toBeVisible();
  await expect(headerSiderCard.locator('.ant-layout-sider')).toContainText('Sider');
  await expect(headerSiderCard.locator('.ant-layout-content')).toContainText('Content');

  const collapsibleCard = page.locator('.docs-section-card').filter({ hasText: 'Collapsible sider' });
  await expect(collapsibleCard.locator('.ant-layout-sider')).toBeVisible();
  await expect(collapsibleCard.locator('.ant-layout-sider-collapsed')).toBeVisible();
  await expect(collapsibleCard.locator('.ant-layout-content')).toContainText('Content with collapsible navigation');

  const responsiveCard = page.locator('.docs-section-card').filter({ hasText: 'Responsive sider' });
  await expect(responsiveCard.locator('.ant-layout-sider')).toBeVisible();
  await expect(responsiveCard.locator('.ant-layout-sider')).toContainText('Responsive sider');
  await expect(responsiveCard.locator('.ant-layout-content')).toContainText('Resize the page to let the sider collapse at the large breakpoint.');
});