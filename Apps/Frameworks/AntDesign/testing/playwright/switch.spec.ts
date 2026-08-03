import { test, expect } from './harnessFixture';

test('renders the switch component documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Switch' }).click();

  await expect(page).toHaveURL(/#\/components\/switch/);
  await expect(page.getByRole('heading', { name: 'Switch' }).first()).toBeVisible();
  await expect(
    page.getByText(
      'Creates an antd-switch descriptor that maps the PowerShell command surface to the Ant Design Switch component used by the client runtime. The command mirrors the core Switch API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs while still supporting PowerShell Universal endpoint callbacks.',
    ),
  ).toBeVisible();

  const whenToUseCard = page.locator('.docs-section-card').filter({ hasText: 'When To Use' });
  await expect(
    whenToUseCard.getByText('If you need to represent the switching between two states or on-off state.'),
  ).toBeVisible();
  await expect(
    whenToUseCard.getByText(
      'The difference between Switch and Checkbox is that Switch will trigger a state change directly when you toggle it, while Checkbox is generally used for state marking, which should work in conjunction with submit operation.',
    ),
  ).toBeVisible();
  await expect(page.getByText('Basic', { exact: true })).toBeVisible();
  await expect(page.getByText('Text & icon', { exact: true })).toBeVisible();
  await expect(page.getByText('Custom semantic dom styling', { exact: true })).toBeVisible();
  await expect(page.getByText('New-UDAntDesignSwitch -DefaultChecked $true -Size small')).toBeVisible();
});

test('shows live previews for the documented switch examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Switch' }).click();

  const basicCard = page.locator('.docs-section-card').filter({ hasText: 'Basic' });
  const basicPreviewSurface = basicCard.locator('.docs-preview-surface').first();
  await expect(basicCard.locator('.ant-switch').first()).toBeVisible();
  await expect(basicCard.locator('.ant-switch').nth(1)).toHaveClass(/ant-switch-checked/);

  const basicPreviewSurfaceBox = await basicPreviewSurface.boundingBox();
  const basicSwitchBox = await basicCard.locator('.ant-switch').first().boundingBox();

  expect(basicPreviewSurfaceBox).not.toBeNull();
  expect(basicSwitchBox).not.toBeNull();
  expect(basicSwitchBox!.width).toBeLessThan(basicPreviewSurfaceBox!.width);

  const disabledCard = page.locator('.docs-section-card').filter({ hasText: 'Disabled' });
  await expect(disabledCard.locator('.ant-switch').first()).toHaveClass(/ant-switch-disabled/);

  const textIconCard = page.locator('.docs-section-card').filter({ hasText: 'Text & icon' });
  await expect(textIconCard.locator('.ant-switch-inner').first()).toContainText('0');
  await expect(textIconCard.locator('.anticon-check').first()).toBeVisible();

  const sizeCard = page.locator('.docs-section-card').filter({ hasText: 'Two sizes' });
  await expect(sizeCard.locator('.ant-switch').nth(1)).toHaveClass(/ant-switch-small/);

  const loadingCard = page.locator('.docs-section-card').filter({ hasText: 'Loading' });
  await expect(loadingCard.locator('.ant-switch-loading-icon').first()).toBeVisible();
});