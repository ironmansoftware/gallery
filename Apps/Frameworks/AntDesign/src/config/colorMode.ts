export type ColorModePreference = 'system' | 'light' | 'dark';
export type ResolvedColorMode = 'light' | 'dark';

const COLOR_MODE_STORAGE_KEY = 'ud-color-mode';
const COLOR_MODE_MEDIA_QUERY = '(prefers-color-scheme: dark)';

function isColorModePreference(value: string | null): value is ColorModePreference {
  return value === 'system' || value === 'light' || value === 'dark';
}

export function readStoredColorModePreference(): ColorModePreference {
  try {
    const storedPreference = window.localStorage.getItem(COLOR_MODE_STORAGE_KEY);
    return isColorModePreference(storedPreference) ? storedPreference : 'system';
  } catch {
    return 'system';
  }
}

export function persistColorModePreference(preference: ColorModePreference): void {
  try {
    if (preference === 'system') {
      window.localStorage.removeItem(COLOR_MODE_STORAGE_KEY);
      return;
    }

    window.localStorage.setItem(COLOR_MODE_STORAGE_KEY, preference);
  } catch {
    // Ignore storage access failures and keep the current in-memory preference.
  }
}

export function readSystemColorMode(): ResolvedColorMode {
  return window.matchMedia(COLOR_MODE_MEDIA_QUERY).matches ? 'dark' : 'light';
}

export function resolveColorMode(
  preference: ColorModePreference,
  systemColorMode: ResolvedColorMode,
): ResolvedColorMode {
  return preference === 'system' ? systemColorMode : preference;
}

export function applyResolvedColorMode(colorMode: ResolvedColorMode): void {
  document.documentElement.dataset.colorMode = colorMode;
  document.documentElement.style.colorScheme = colorMode;
}

export function getColorModeMediaQuery(): string {
  return COLOR_MODE_MEDIA_QUERY;
}