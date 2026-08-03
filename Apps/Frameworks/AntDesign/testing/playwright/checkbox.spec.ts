import { expect, test } from './harnessFixture';

test('renders the checkbox component documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Checkbox' }).click();

  await expect(page).toHaveURL(/#\/components\/checkbox/);
  await expect(page.getByRole('heading', { name: 'Checkbox' }).first()).toBeVisible();
  await expect(
    page.getByText(
      'Creates an antd-checkbox descriptor that maps the PowerShell command surface to the Ant Design Checkbox component used by the client runtime. The command mirrors the core Checkbox API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs while still supporting PowerShell Universal endpoint callbacks.',
    ),
  ).toBeVisible();

  const whenToUseCard = page.locator('.docs-section-card').filter({ hasText: 'When To Use' });
  await expect(
    whenToUseCard.getByText('Used for selecting multiple values from several options.'),
  ).toBeVisible();
  await expect(
    whenToUseCard.getByText(
      'If you use only one checkbox, it is the same as using Switch to toggle between two states. The difference is that Switch will trigger the state change directly, but Checkbox just marks the state as changed and this needs to be submitted.',
    ),
  ).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Basic' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Disabled' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Indeterminate' })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: 'Custom styling' })).toBeVisible();
  await expect(page.getByText("New-UDAntDesignCheckbox -Label 'Partially selected permissions' -Indeterminate")).toBeVisible();
});

test('shows live previews for the documented checkbox examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Checkbox' }).click();

  const basicCard = page.locator('.docs-section-card').filter({ hasText: 'Basic' });
  await expect(basicCard.locator('.ant-checkbox').first()).toBeVisible();
  await expect(basicCard.locator('.ant-checkbox').nth(1)).toHaveClass(/ant-checkbox-checked/);
  await expect(basicCard.locator('.ant-checkbox-label').filter({ hasText: 'Remember me' })).toBeVisible();
  await expect(basicCard.locator('.ant-checkbox-label').filter({ hasText: 'Send status updates' })).toBeVisible();

  const disabledCard = page.locator('.docs-section-card').filter({ hasText: 'Disabled' });
  await expect(disabledCard.locator('.ant-checkbox-wrapper').first()).toHaveClass(/ant-checkbox-wrapper-disabled/);
  await expect(disabledCard.locator('.ant-checkbox').nth(1)).toHaveClass(/ant-checkbox-checked/);

  const indeterminateCard = page.locator('.docs-section-card').filter({ hasText: 'Indeterminate' });
  await expect(indeterminateCard.locator('.ant-checkbox')).toHaveClass(/ant-checkbox-indeterminate/);
  await expect(
    indeterminateCard.locator('.ant-checkbox-label').filter({ hasText: 'Partially selected permissions' }),
  ).toBeVisible();

  const styledCard = page.locator('.docs-section-card').filter({ hasText: 'Custom styling' });
  await expect(styledCard.locator('.ant-checkbox-wrapper').filter({ hasText: 'Styled option' })).toHaveCSS(
    'color',
    'rgb(212, 107, 8)',
  );
});