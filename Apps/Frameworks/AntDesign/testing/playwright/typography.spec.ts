import { test, expect } from './harnessFixture';

test('renders the typography documentation from comment-based help', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Typography' }).click();

  await expect(page).toHaveURL(/#\/components\/typography/);
  await expect(page.getByRole('heading', { name: 'Typography' }).first()).toBeVisible();
  const whenToUseCard = page.locator('.docs-section-card').filter({ hasText: 'When To Use' });
  await expect(
    whenToUseCard.getByText('Basic text writing, including headings, body text, lists, and more.').first(),
  ).toBeVisible();
  await expect(whenToUseCard.getByText('When you need copyable, editable, or ellipsis text treatments.')).toBeVisible();
  await expect(
    page.getByText("New-UDAntDesignTypography -Kind title -Level 1 -Text 'h1. Ant Design'"),
  ).toBeVisible();
  await expect(
    page.getByText("New-UDAntDesignTypography -Text 'This is a copyable text.' -Copyable"),
  ).toBeVisible();
});

test('shows live previews for the documented typography examples', async ({ page, harness }) => {
  await harness.gotoShell(page);

  await page.getByRole('menuitem', { name: 'Typography' }).click();

  const titleCard = page.locator('.docs-section-card').filter({ hasText: 'Title Component' });
  const textAndLinkCard = page.locator('.docs-section-card').filter({ hasText: 'Text and Link Component' });
  const copyableCard = page.locator('.docs-section-card').filter({ hasText: 'Copyable' });

  await expect(titleCard.getByRole('heading', { name: 'h1. Ant Design' }).first()).toBeVisible();
  await expect(textAndLinkCard.locator('span.ant-typography').filter({ hasText: 'Ant Design (secondary)' }).first()).toHaveClass(
    /ant-typography-secondary/,
  );
  await expect(textAndLinkCard.getByRole('link', { name: 'Ant Design (Link)' })).toHaveAttribute('href', 'https://ant.design/');
  await expect(copyableCard.locator('.docs-preview-surface .ant-typography-copy').first()).toBeVisible();

  const ellipsisCard = page.locator('.docs-section-card').filter({ hasText: 'Ellipsis' });
  const ellipsisSurface = ellipsisCard.locator('.docs-preview-surface').first();
  await ellipsisSurface.getByText('Expand').click();
  await expect(ellipsisSurface).toContainText(
    'Ant Design, a design language for background applications, is refined by Ant UED Team. Ant Design, a design language for background applications, is refined by Ant UED Team.',
  );
});