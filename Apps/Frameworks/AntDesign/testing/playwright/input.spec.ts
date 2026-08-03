import { expect, test } from './harnessFixture';

test('renders the input component documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Input' }).click();

  await expect(page).toHaveURL(/#\/components\/input/);
  await expect(page.getByRole('heading', { name: 'Input' }).first()).toBeVisible();
  await expect(
    page.getByText(
      'Creates an antd-input descriptor that maps the PowerShell command surface to the Ant Design Input family used by the client runtime.',
    ),
  ).toBeVisible();

  const whenToUseCard = page.locator('.docs-section-card').filter({ hasText: 'When To Use' });
  await expect(whenToUseCard.getByText('A user input in a form field is needed.')).toBeVisible();
  await expect(whenToUseCard.getByText('A search input is required.')).toBeVisible();

  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: /^Basic usage$/ })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: /^Search box$/ })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: /^OTP$/ })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: /^Custom count logic$/ })).toBeVisible();
  await expect(page.locator('.docs-section-card .ant-card-head-title').filter({ hasText: /^Custom semantic dom styling$/ })).toBeVisible();
  await expect(page.getByText("New-UDAntDesignInput -Mode search -Placeholder 'input search text' -EnterButton $true")).toBeVisible();
});

test('shows live previews for the documented input examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Input' }).click();

  const basicCard = page.locator('.docs-section-card').filter({ hasText: 'Basic usage' });
  await expect(basicCard.getByPlaceholder('Basic usage')).toBeVisible();

  const sizeCard = page.locator('.docs-section-card').filter({ hasText: 'Three sizes of Input' });
  await expect(sizeCard.getByPlaceholder('large size')).toBeVisible();
  await expect(sizeCard.getByPlaceholder('default size')).toBeVisible();
  await expect(sizeCard.getByPlaceholder('small size')).toBeVisible();

  const searchCard = page.locator('.docs-section-card').filter({ hasText: 'Search box' });
  await expect(searchCard.getByPlaceholder('input search text').first()).toBeVisible();
  await expect(searchCard.getByRole('button', { name: 'Search' }).first()).toBeVisible();

  const textareaCard = page.locator('.docs-section-card').filter({ hasText: 'TextArea' });
  await expect(textareaCard.locator('textarea').first()).toBeVisible();
  await expect(textareaCard.getByPlaceholder('maxLength is 6')).toBeVisible();

  const otpCard = page.locator('.docs-section-card').filter({ hasText: 'OTP' });
  await expect(otpCard.getByRole('heading', { name: 'With formatter (Upcase)' })).toBeVisible();
  await expect(otpCard.locator('input').nth(5)).toBeVisible();

  const passwordCard = page.locator('.docs-section-card').filter({ hasText: 'Password box' });
  await expect(passwordCard.getByPlaceholder('input password').first()).toBeVisible();
  await expect(passwordCard.getByPlaceholder('disabled input password')).toBeVisible();

  const countCard = page.locator('.docs-section-card').filter({ hasText: 'With character counting' });
  await expect(countCard.locator('.ant-input-show-count-suffix').first()).toBeVisible();

  const statusCard = page.locator('.docs-section-card').filter({ hasText: 'Status' });
  await expect(statusCard.getByPlaceholder('Error with prefix')).toBeVisible();
  await expect(statusCard.getByPlaceholder('Warning with prefix')).toBeVisible();
});