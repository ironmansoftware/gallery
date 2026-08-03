import { test, expect } from './harnessFixture';

test('renders the rate component documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Rate' }).click();

  await expect(page).toHaveURL(/#\/components\/rate/);
  await expect(page.getByRole('heading', { name: 'Rate' }).first()).toBeVisible();
  await expect(
    page.getByText(
      'Creates an antd-rate descriptor that maps the PowerShell command surface to the Ant Design Rate component used by the client runtime. The command mirrors the core Rate API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs while still supporting PowerShell Universal endpoint callbacks.',
    ),
  ).toBeVisible();

  const whenToUseCard = page.locator('.docs-section-card').filter({ hasText: 'When To Use' });
  await expect(whenToUseCard.getByText('Show evaluation.')).toBeVisible();
  await expect(whenToUseCard.getByText('A quick rating operation on something.')).toBeVisible();
  await expect(page.getByText('Half star', { exact: true })).toBeVisible();
  await expect(page.getByText('Clear star', { exact: true })).toBeVisible();
  await expect(page.getByText('Other character', { exact: true })).toBeVisible();
  await expect(page.getByText('New-UDAntDesignRate -AllowHalf:$true -DefaultValue 2.5')).toBeVisible();
});

test('shows live previews for the documented rate examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Rate' }).click();

  const basicCard = page.locator('.docs-section-card').filter({ hasText: 'Basic' });
  await expect(basicCard.locator('.ant-rate')).toBeVisible();
  await expect(basicCard.locator('.ant-rate-star')).toHaveCount(5);

  const sizesCard = page.locator('.docs-section-card').filter({ hasText: 'Sizes' });
  await expect(sizesCard.locator('.ant-rate').first()).toHaveCSS('font-size', '15px');
  await expect(sizesCard.locator('.ant-rate').nth(1)).toHaveCSS('font-size', '20px');
  await expect(sizesCard.locator('.ant-rate').nth(2)).toHaveCSS('font-size', '25px');

  const halfStarCard = page.locator('.docs-section-card').filter({ hasText: 'Half star' });
  await expect(halfStarCard.locator('.ant-rate-star-half').first()).toBeVisible();

  const readOnlyCard = page.locator('.docs-section-card').filter({ hasText: 'Read only' });
  await expect(readOnlyCard.locator('.ant-rate')).toHaveClass(/ant-rate-disabled/);

  const otherCharacterCard = page.locator('.docs-section-card').filter({ hasText: 'Other character' });
  await expect(otherCharacterCard.locator('.anticon-heart').first()).toBeVisible();
  await expect(otherCharacterCard.getByText('A').first()).toBeVisible();
  await expect(otherCharacterCard.getByText('好').first()).toBeVisible();
});