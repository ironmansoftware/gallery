declare module 'universal-dashboard' {
  import type { ComponentType } from 'react';

  export function withComponentFeatures<TProps extends Record<string, unknown>>(
    component: ComponentType<TProps>,
  ): ComponentType<TProps>;
}