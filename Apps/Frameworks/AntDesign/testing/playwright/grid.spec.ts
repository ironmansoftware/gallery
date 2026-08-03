import { expect, test } from './harnessFixture';

test('renders the grid component documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Grid' }).click();

  await expect(page).toHaveURL(/#\/components\/grid/);
  await expect(page.getByRole('heading', { name: 'Grid' }).first()).toBeVisible();
  await expect(
    page.getByText(
      'Creates an antd-row descriptor that maps the PowerShell command surface to the Ant Design Row component used by the client runtime. Use grid rows as the outer layout container for Ant Design grid columns so dashboard content can be arranged in the standard 24-column grid system.',
    ),
  ).toBeVisible();
  await expect(page.getByText('When To Use', { exact: true })).toBeVisible();
  await expect(
    page.getByText('Use rows to define horizontal layout bands and place only Ant Design grid columns directly inside the row content.'),
  ).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Basic grid' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Responsive gutter' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Justify and align' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Flex fill' })).toBeVisible();
  await expect(page.getByText('New-UDAntDesignCol -Span 12 -Content (New-UDAntDesignText -Text \'col-12\')')).toBeVisible();
});

test('shows live previews for the documented grid examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Grid' }).click();

  const basicCard = page.locator('.docs-section-card').filter({ hasText: 'Basic grid' });
  await expect(basicCard.locator('.ant-row')).toBeVisible();
  await expect(basicCard.locator('.ant-col-12')).toHaveCount(2);
  await expect(basicCard.locator('.ant-row .ant-col-12 .ant-typography').filter({ hasText: 'col-12' })).toHaveCount(2);

  const responsiveCard = page.locator('.docs-section-card').filter({ hasText: 'Responsive gutter' });
  await expect(responsiveCard.locator('.ant-row')).toBeVisible();
  await expect(
    responsiveCard.locator('.ant-row .ant-typography').filter({ hasText: 'Responsive gutter' }),
  ).toBeVisible();
  await expect(
    responsiveCard.locator('.ant-row .ant-typography').filter({ hasText: 'Horizontal and vertical spacing' }),
  ).toBeVisible();

  const justifyCard = page.locator('.docs-section-card').filter({ hasText: 'Justify and align' });
  await expect(justifyCard.locator('.ant-row-space-between')).toBeVisible();
  await expect(justifyCard.locator('.ant-row-middle')).toBeVisible();
  await expect(justifyCard.locator('.ant-row .ant-typography').filter({ hasText: 'Left' })).toBeVisible();
  await expect(justifyCard.locator('.ant-row .ant-typography').filter({ hasText: 'Center' })).toBeVisible();
  await expect(justifyCard.locator('.ant-row .ant-typography').filter({ hasText: 'Right' })).toBeVisible();

  const orderCard = page.locator('.docs-section-card').filter({ hasText: 'Offset and order' });
  await expect(orderCard.locator('.ant-col-offset-6')).toBeVisible();
  await expect(orderCard.locator('.ant-row .ant-typography').filter({ hasText: 'First with offset' })).toBeVisible();
  await expect(
    orderCard.locator('.ant-row .ant-typography').filter({ hasText: 'Second in visual order' }),
  ).toBeVisible();

  const flexCard = page.locator('.docs-section-card').filter({ hasText: 'Flex fill' });
  await expect(flexCard.locator('.ant-row .ant-typography').filter({ hasText: '100px' })).toBeVisible();
  await expect(flexCard.locator('.ant-row .ant-typography').filter({ hasText: 'Auto width' })).toBeVisible();
  await expect(
    flexCard.locator('.ant-row .ant-typography').filter({ hasText: 'Flexible remainder' }),
  ).toBeVisible();
});