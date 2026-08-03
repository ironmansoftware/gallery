# Dashboard Framework Agent Guide

This document is for agents building an alternate PowerShell Universal dashboard framework that still speaks the existing PSU app runtime contract.

This guide documents public behavior and framework mechanics. It intentionally avoids naming PSU server implementation types and focuses on what the framework must send, receive, render, and host.

## Normative Language

The keywords `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, and `MAY` are normative in this document.

- `MUST` and `MUST NOT` identify hard compatibility requirements.
- `SHOULD` and `SHOULD NOT` identify strong recommendations that may be violated only with a clear compatibility reason.
- `MAY` identifies optional behavior.

Target scenario:

- The PowerShell module emits hashtable descriptors, similar to the current framework.
- The browser UI is implemented with a different React component library such as Ant Design or Semantic UI.
- Static assets are served from a module-provided published folder, not through server-managed framework resolution or the dynamic JavaScript asset route unless lazy plugin loading is explicitly required.

## Scope

The reusable contract is not Material UI. The reusable contract is:

- initial app bootstrap over HTTP
- incremental interaction over SignalR (`/dashboardhub`)
- generic component event execution over HTTP (`/api/internal/component/element/{id}`)
- descriptor materialization via the React registration and render pipeline

If a replacement framework preserves that contract, it can swap the visual component library without changing the server-side dashboard programming model.

## Standard Reference Stack

Future agents `SHOULD` use the same reference stack unless a concrete compatibility problem requires a different choice.

Required choices:

- React `MUST` be the component runtime.
- TypeScript `MUST` be used for all framework source code.
- Vite `MUST` be the build tool, dev server, and transpilation pipeline.
- `@microsoft/signalr` `MUST` be the websocket transport client.
- Zustand `MUST` be the client runtime state library.
- `universal-dashboard` `MUST` be referenced when using the stock compatibility wrapper so `withComponentFeatures` comes from the published package instead of a local rewrite.

Preferred choices:

- TanStack Query `SHOULD` be used for HTTP request lifecycle management.
- TanStack Router `SHOULD` be used when the framework supports client-side page routing such as `New-UDPage`-style navigation.
- Zod `SHOULD` be used to validate bootstrap payloads, endpoint descriptors, and websocket payloads at the transport boundary.
- React Hook Form `SHOULD` be used for complex framework-owned form components.
- `react-error-boundary` `SHOULD` be used for shell-level and component-level error boundaries.
- Vitest and Testing Library `SHOULD` be the default test stack for unit and component tests.
- Playwright `SHOULD` be used for browser-level integration coverage when validating transport and descriptor behavior end to end.
- MSW `SHOULD` be used for HTTP mocking in unit and component tests.

Rejected defaults:

- Redux `SHOULD NOT` be used unless Zustand proves insufficient for a specific requirement.
- Next.js, Remix, or other server-rendering-first frameworks `SHOULD NOT` be used as the shell foundation for this framework.
- React Router or another client-side routing library `SHOULD NOT` be introduced by default when TanStack Router can satisfy the framework's page-routing needs.
- Any client-side routing library `SHOULD NOT` be introduced unless the framework actually owns page navigation beyond a single shell view.
- webpack `SHOULD NOT` be selected for new work when Vite can satisfy the build and dev workflow.

UI component libraries are intentionally not standardized here. The framework is meant to wrap UI libraries, not prescribe one. Agents `MAY` choose the UI library that best fits the framework being implemented as long as the transport, descriptor, state, and wrapper contracts in this document are preserved.

## TypeScript Requirements

TypeScript is mandatory.

The framework:

- `MUST` compile from TypeScript source
- `MUST` enable `strict` mode
- `MUST` enable `noUncheckedIndexedAccess`
- `MUST` enable `exactOptionalPropertyTypes`
- `SHOULD` model dashboard descriptors, websocket messages, and endpoint descriptors as explicit types
- `SHOULD` keep transport-layer inputs typed as `unknown` until validated

The framework `MUST NOT` rely on untyped JavaScript for core transport, state, descriptor, or component-registry logic.

## Build And Tooling Requirements

Vite is the standard toolchain.

The framework:

- `MUST` use Vite for local development and production builds
- `SHOULD` use the Vite React plugin with SWC for faster iteration
- `SHOULD` produce a static `dist` output suitable for publication through `.universal/publishedFolders.ps1`
- `SHOULD` keep the bundle structure simple enough that future agents can reason about entry points, lazy chunks, and published assets quickly

Linting and formatting:

- a single automated linting setup `MUST` be present
- a single automated formatting setup `SHOULD` be present
- agents `SHOULD NOT` introduce multiple competing lint or format pipelines

## State Ownership Rules

State ownership must be consistent across all implementations.

Zustand is the source of truth for runtime client state.

The Zustand store `MUST` own:

- shell state such as `dashboardId`, `sessionId`, `pageId`, API base path, and connection status
- descriptor-tree state used to render the page
- component runtime state used by `Set-UDElement` and `Get-UDElement`
- transport status such as reconnecting, connected, disconnected, and last transport error
- transient framework UI state such as snackbars, modals, and progress indicators

TanStack Query, when used, `MUST NOT` be the source of truth for websocket-driven UI state.

TanStack Query is not the transport layer.

TanStack Query `SHOULD` own:

- bootstrap fetch lifecycle
- idempotent GET requests
- cacheable read operations that are not the live descriptor tree
- retry and stale-time policy for HTTP reads

Local component state `SHOULD` be limited to purely presentational or ephemeral UI behavior that does not participate in PSU transport semantics.

Any state needed by `Get-UDElement`, websocket updates, or descriptor-tree mutation `MUST` live in the wrapper or central runtime store, not only in private component state.

## Transport Architecture Rules

The framework `MUST` have a dedicated transport layer.

Components `MUST NOT` call raw `fetch`, raw SignalR connection methods, or download endpoints directly except through the framework transport or wrapper abstractions.

The transport layer `MUST` expose equivalent capabilities for:

- bootstrap dashboard data
- connect and reconnect the websocket session
- publish client events
- invoke HTTP endpoints
- persist session-state fallback data
- start file downloads

The transport layer `SHOULD` validate inputs and outputs at its boundary with Zod or an equivalent schema library.

The transport layer `MUST NOT` be replaced by TanStack Query alone. Query management and transport are separate concerns.

The transport layer `SHOULD` be the only layer that knows:

- raw endpoint URLs
- SignalR connection setup
- retry and reconnect policy
- payload validation and normalization

If the framework supports page-based client routing, the router layer `MUST` derive its active route state from the dashboard page model and stay consistent with the active `pageId` used for server communication.

## Recommended Application Architecture

Future agents `SHOULD` follow this internal module layout even if actual folder names differ:

- `transport`: HTTP and SignalR client code
- `state`: Zustand stores and store selectors
- `routing`: route definitions and page-to-route resolution when the framework supports multi-page dashboards
- `schema`: Zod schemas and transport payload parsers
- `registry`: component registration and descriptor-to-component resolution
- `components`: framework UI components
- `features`: optional higher-level areas such as forms, tables, modals, and notifications
- `testing`: test utilities, mocks, and integration harnesses

The framework `SHOULD` preserve clear boundaries:

- components render UI and raise events
- wrapper logic adapts descriptors into component props and callbacks
- state stores own runtime state
- routing resolves page navigation and URL state when multi-page dashboards are enabled
- transport owns server communication
- schemas own runtime validation

## Modern Conventions For All Agents

Future agents `SHOULD` apply these conventions consistently.

- Prefer schema validation at network boundaries over trusting server payload shape implicitly.
- Prefer small composable hooks over monolithic controller components.
- Prefer store selectors over broad whole-store subscriptions.
- Prefer explicit typed descriptor models over anonymous `Record<string, any>` structures.
- Prefer deterministic fallback rendering over silent failure for unknown component types.
- Prefer command-query separation: websocket and POST endpoint operations mutate state, while GET operations read state.
- Prefer central reconnection handling instead of per-component websocket recovery logic.
- Prefer lazy loading only for optional plugin components, not for the primary shell.
- Prefer one obvious state path for runtime behavior; avoid duplicating the same state across query cache, local state, and a global store.

## Testing Expectations

The framework `SHOULD` include three levels of testing.

- unit tests for descriptor parsing, schemas, selectors, and transport helpers
- component tests for wrapped components, state updates, and endpoint callback behavior
- browser or integration tests for bootstrap, websocket flows, downloads, and tree mutation behaviors

The minimum useful automated coverage `SHOULD` prove:

- bootstrap from `/api/internal/dashboard`
- websocket connection and required message handling
- `Set-UDElement` and `Get-UDElement` behavior
- descriptor-tree mutation behavior for `addElement`, `clearElement`, `removeElement`, and `syncElement`
- download handling from `/api/internal/dashboard/download/{dashboardId}/{id}`

## Development Harness

Framework development and browser-level testing `SHOULD` use the local harness in `Apps/Frameworks/Harness` instead of requiring a full PSU runtime.

The harness exists to host framework bundles against the documented dashboard contract with only the minimum server behavior a framework needs:

- static asset hosting through published-folder style request paths
- bootstrap over `/api/internal/dashboard`
- HTTP component execution over `/api/internal/component/element/{id}`
- session-state fallback over `/api/internal/component/element/sessionState/{requestId}`
- downloads over `/api/internal/dashboard/download/{dashboardId}/{id}`
- SignalR traffic over `/dashboardhub`
- PowerShell-backed endpoint and event execution for local iteration

Agent guidance:

- framework authors `SHOULD` point their local shell, bundle, and static assets at the harness during development
- Playwright and other browser-level tests `SHOULD` run against the harness by default
- agents `SHOULD NOT` require a full PSU instance just to validate framework transport behavior, endpoint execution, or websocket message handling unless a test explicitly depends on PSU-only features outside this contract
- if harness behavior is insufficient for a new framework need, extend the harness before introducing PSU runtime setup as the default workflow

## Asset Hosting Rules

Baseline context:

- the stock framework ships a built-in client bundle and supports plugin-style lazy component loading
- plugin-style components can mark descriptors with `isPlugin = $true` and `assetId`, which causes the browser to fetch `/api/internal/javascript/{assetId}?dashboardId={id}`.
- the fetched script is expected to register components through `window.UniversalDashboard.register(type, component)`.

Conformance rules:

- A new framework `MUST NOT` depend on server-side framework resolution.
- A new framework `MUST NOT` depend on `/api/internal/javascript/{asset}` for its normal bundle.
- A new framework `MUST` ship its compiled JS and CSS in the framework module.
- A new framework `MUST` expose those files through a module-provided `.universal/publishedFolders.ps1`.
- A new framework `MUST` load its primary bundle from the published folder like any other static asset.

The dynamic JavaScript asset endpoint `MAY` be used only for intentional plugin-style lazy loading by `assetId`.

## Static Asset Model

Published folders are the required hosting model for framework-owned static assets.

Framework assumptions:

- each published folder exposes a catch-all route from its configured `RequestPath`
- the route shape is `/{requestPath}/{**subPath}`
- the server serves the underlying files from the configured folder path
- path traversal is blocked before dispatch

Example declaration from `.universal/publishedFolders.ps1`:

```powershell
New-PSUPublishedFolder -Name 'PublishedFolder' -RequestPath '/images' -Path 'C:\images' -DefaultDocument @('') -Authentication -Role @('Administrator')
```

For a framework module, the same pattern can expose a built UI bundle:

```powershell
New-PSUPublishedFolder -Name 'MyFrameworkAssets' `
    -RequestPath '/frameworks/my-framework' `
    -Path "$PSScriptRoot/../dist"
```

Then the app can reference assets such as:

- `/frameworks/my-framework/app.js`
- `/frameworks/my-framework/app.css`

Conformance rules:

- Framework-owned JS, CSS, images, fonts, and similar static assets `MUST` be delivered from a published folder.
- A framework `SHOULD` use stable, framework-specific request paths such as `/frameworks/my-framework`.
- A framework `SHOULD NOT` route ordinary static assets through dynamic component-loading endpoints.
- A framework `MAY` use authenticated or role-protected published folders when the framework requires restricted access.

## Browser Bootstrap Contract

The browser shell requires two pieces of routing state from meta tags:

- `baseurl` controls the API prefix
- `ud-dashboard` provides the dashboard id when local storage does not override it

If a replacement frontend hosts its own shell page, it still needs equivalents for:

- API base path
- dashboard id
- current location and base URL handling

The first required HTTP call is:

```text
GET /api/internal/dashboard
```

The response includes:

- `dashboard`: the root descriptor tree for the page
- `sessionId`: dashboard session identifier
- `pageId`: current page identifier
- `authType`
- `roles`
- `user`
- `idleTimeout`
- `dashboardName`
- `developerLicense`

Conformance rules:

- The browser shell `MUST` perform `GET /api/internal/dashboard` before initial render.
- The browser shell `MUST` treat `dashboard` as the root descriptor tree.
- The browser shell `MUST` preserve `sessionId` and `pageId` for subsequent websocket communication.
- The browser shell `SHOULD` preserve `authType`, `roles`, `user`, and timeout-related values for any UI or behavior that depends on them.
- The browser shell `MUST` honor the effective API base path when constructing all API requests.

## Websocket Contract

The browser connects to SignalR at:

```text
/dashboardhub?dashboardid={dashboardId}&pageid={pageId}&sessionid={sessionId}&timezone={timezone}
```

The server sends websocket messages identified by a `messageType` and payload. Some interactions are fire-and-forget, and some expect a direct result, such as state requests.

Extended message set:

- `setState`
- `requestState`
- `addElement`
- `clearElement`
- `removeElement`
- `syncElement`
- `download`
- `redirect`
- `showToast`
- `showSnackbar`
- `hideSnackbar`
- `showModal`
- `closeModal`
- `invoke`
- `invokeMethod`
- `invokejavascript`
- `invokejavascriptreturn`
- `progress`
- `clipboard`
- `select`
- `refresh`
- `write`
- `log`

Required baseline message set:

- `setState`
- `requestState`
- `addElement`
- `clearElement`
- `removeElement`
- `syncElement`
- `download`
- `redirect`

Conformance rules:

- The browser shell `MUST` connect to `/dashboardhub` using `dashboardId`, `pageId`, `sessionId`, and `timezone`.
- The browser shell `MUST` implement the required baseline message set.
- The browser shell `SHOULD` implement the extended message set when parity with the stock experience is required.
- The browser shell `MUST` return state for request-response websocket flows that expect a direct result.
- The browser shell `MUST` preserve the message type names exactly as documented here.

## Descriptor Materialization

The browser-side rendering contract is based on a simple registry-and-render pattern.

Render pipeline:

1. The root descriptor returned by `/api/internal/dashboard` is passed into the render service.
2. The render service locates a registered React component by `component.type`.
3. If found, it renders that component with the descriptor spread as props.
4. If the descriptor is marked `isPlugin` and the component is not already loaded, the browser MAY lazily load a script from `/api/internal/javascript/{assetId}` and retry rendering.
5. If no matching component exists, the framework MUST render a deterministic fallback or error component.

Conformance rules:

- PowerShell descriptor output `MUST` remain plain serializable objects.
- The browser `MUST` map `type` to a registered React component or equivalent render target.
- Child content `MUST` remain recursively renderable descriptors or primitive values.
- A framework `MUST NOT` change descriptor semantics merely to match a UI library preference.

The replacement UI library changes how the React component renders, not how the descriptor is shaped.

## `withComponentFeatures`

A compatibility helper named `withComponentFeatures` is the main wrapper used to make framework components behave like PSU dashboard components. Its behavior is normative even if the implementation is rewritten.

Preferred source:

- agents `SHOULD` import `withComponentFeatures` from the `universal-dashboard` npm package when the package satisfies the framework's compatibility needs
- agents `SHOULD NOT` reimplement `withComponentFeatures` unless a concrete compatibility gap in `universal-dashboard` forces that divergence

Required wrapper capabilities:

- `render(component)`
- `setState(state)`
- `publish(topic, payload)`
- `notifyOfEvent(eventName, eventData)`
- `post(path, body)`
- `get(path)`
- `subscribeToIncomingEvents(callback)`
- `unsubscribeFromIncomingEvents(token)`
- `newEndpoint(endpoint)`

Required incoming event handling:

- `setState`
- `getState`
- `requestState`
- `addElement`
- `clearElement`
- `removeElement`
- `syncElement`

Conformance rules:

- A conforming framework `MUST` provide behavior equivalent to `withComponentFeatures`.
- A conforming framework `SHOULD` use `import { withComponentFeatures } from 'universal-dashboard'` rather than maintaining a forked local wrapper.
- Interactive components `MUST` receive wrapped endpoint callbacks instead of raw endpoint descriptor objects.
- Interactive components `MUST` be able to receive incoming events addressed to their component id.
- State that must participate in request-state flows `MUST` be tracked through the wrapper state mechanism, not only local UI state.

## Endpoint Handling

PowerShell event handlers arrive in descriptors as endpoint-shaped objects. The wrapper converts those descriptors into callable JavaScript functions.

The client-side wrapper distinguishes three cases.

### 1. Inline JavaScript endpoint

If the endpoint contains `javaScript`, the wrapper builds:

```javascript
new Function('data', endpoint.javaScript)
```

This path `SHOULD` be used only when the server intentionally emitted client-side JavaScript.

### 2. Websocket endpoint

If the endpoint contains `websocket`, the wrapper publishes an `element-event` message with:

- `type: 'clientEvent'`
- `eventId: endpoint.name`
- `eventName: endpoint.name`
- `eventData: data`

The browser shell `MUST` bridge that PubSub event to SignalR by invoking the hub `event` method and adding the current browser location.

This is the low-latency path used by `Set-UDElement`, `Get-UDElement`, downloads, and other server-driven interactions.

### 3. HTTP endpoint

Otherwise the wrapper issues:

```text
POST /api/internal/component/element/{endpoint.name}
```

Optional endpoint metadata influences the request:

- `accept` sets the `Accept` header
- `contentType` sets the `Content-Type` header

The HTTP path SHOULD append a query string only when the caller passes `options.query`, while still sending the main payload as the request body.

The framework must treat these as the generic component execution endpoints:

- `GET /api/internal/component/element/{id}`
- `POST /api/internal/component/element/{id}`

Conformance rules:

- An endpoint descriptor with `javaScript` `MUST` execute in the browser.
- An endpoint descriptor with `websocket` `MUST` publish a client event over the websocket path.
- Any other endpoint descriptor `MUST` issue an HTTP request to `/api/internal/component/element/{endpoint.name}`.
- The HTTP endpoint path `MUST` preserve `Accept` and `Content-Type` metadata when provided.
- The HTTP endpoint path `SHOULD` support optional query-string augmentation through `options.query`.
- Component execution endpoints `MUST` support JSON, plain text, and multipart form data.

## Generic Interactive Cmdlet Semantics

These cmdlets are not framework-specific. A conforming framework `MUST` preserve the browser behavior they rely on.

### `Set-UDElement`

Behavior:

- sends websocket message type `setState`
- payload includes `componentId` and `state`
- if `-Content` is provided, child content is materialized and assigned into `state.content`

Framework requirement:

- when the component receives `setState` for its id, it `MUST` merge or replace local state and rerender

### `Get-UDElement`

Behavior:

- creates a request id
- sends websocket message type `requestState`
- waits for direct websocket result
- if the direct result is `null`, falls back to persisted session state lookup

Framework requirement:

- on `requestState`, the component `MUST` read its current component state and return it
- if direct return is not possible, the framework `MUST` support the session state fallback route below

Session-state fallback endpoint:

```text
POST /api/internal/component/element/sessionState/{requestId}
```

### `Invoke-UDDownload` / `Start-UDDownload`

Behavior:

- server stores a temporary download in the dashboard session
- server sends websocket message type `download` with `id` and `fileName`
- browser downloads from:

```text
GET /api/internal/dashboard/download/{dashboardId}/{id}
```

Framework requirement:

- create an anchor or equivalent browser download action when `download` arrives

### `Remove-UDElement`, `Clear-UDElement`, `Add-UDElement`, `Sync-UDElement`

These are all transport-level operations on the descriptor tree.

Browser requirements:

- `removeElement`: `MUST` delete one child or target element
- `clearElement`: `MUST` remove children or content from a target
- `addElement`: `MUST` append or insert new descriptor content
- `syncElement`: `MUST` replace or refresh a target subtree with new descriptor content

If these are implemented correctly, many higher-level PowerShell cmdlets work automatically.

## Component Authoring Rules

For a replacement React framework:

1. Each component type `MUST` be registered with a framework registry such as `registerComponent(type, component)` or an equivalent API.
2. Interactive components `MUST` be wrapped with `withComponentFeatures` or an equivalent compatibility wrapper.
3. Descriptor props `MUST` be treated as the source of truth for:
   - `id`
   - child `content`
   - event endpoints such as `onClick`, `onChange`, or custom handlers
4. PSU endpoint descriptors `MUST` be converted into real JS callbacks through `newEndpoint(...)` or equivalent behavior.
5. Child rendering `MUST` remain recursive through the provided `render(...)` helper or equivalent behavior.

Normative example shape:

```javascript
import React from 'react';
import { Button } from 'antd';
import { withComponentFeatures } from 'universal-dashboard';
import { registerComponent } from '../registry';

const UDButton = props => {
  const onClick = props.onClick;

  return (
    <Button id={props.id} onClick={() => onClick && onClick({ value: props.value })}>
      {props.text}
    </Button>
  );
};

registerComponent('my-button', withComponentFeatures(UDButton));
```

The UI library choice is not the compatibility boundary. The compatibility boundary is that the wrapper turns a PowerShell endpoint descriptor into an executable callback while preserving recursive rendering and incoming state updates.

## Extracted Example Patterns

The examples below are intentionally self-contained so future agents can reason about the framework contract without opening the stock implementation.

### Example PowerShell descriptor

This is the general shape of a PowerShell component descriptor:

```powershell
function New-UDExampleButton {
    param(
        [string]$Id = [Guid]::NewGuid(),
        [string]$Text,
        [Endpoint]$OnClick
    )

    $OnClick.Register($Id, $PSCmdlet)

    @{
        type = 'example-button'
        id = $Id
        text = $Text
        onClick = $OnClick
    }
}
```

Normative interpretation:

- `type` `MUST` select the browser component
- `id` `MUST` be the address used for incoming state and tree mutation messages
- endpoint-valued properties such as `onClick` `MUST` be converted into callable JavaScript callbacks by the framework wrapper
- additional scalar properties `MUST` become normal component props unless the component contract says otherwise

### Example endpoint descriptor behavior

An endpoint property should be treated as an object descriptor, not as an already-executable function. The wrapper is responsible for turning it into a callable callback.

Conformance rules:

- if the endpoint declares `javaScript`, execute that JavaScript in the browser
- if the endpoint declares `websocket`, publish a client event over the websocket path
- otherwise POST to `/api/internal/component/element/{endpoint.name}`

### Example wrapped React component

```javascript
const ExampleButton = props => {
  const onClick = props.onClick;

  return (
    <button id={props.id} onClick={() => onClick && onClick({ value: props.value })}>
      {props.text}
    </button>
  );
};

registerComponent('example-button', withComponentFeatures(ExampleButton));
```

Normative interpretation:

- the component `MUST` read ordinary descriptor props like `id` and `text`
- event props like `onClick` `MUST` already be wrapped into callable functions before component use
- child descriptors `MUST` be rendered recursively through the provided `render(...)` helper rather than handled as raw objects

### Example stateful component pattern

If a component exposes state that should be visible to `Get-UDElement`, that state `MUST` be updated through the wrapper's `setState(...)` helper instead of being managed only in local React state.

```javascript
const ExampleInput = props => {
  return (
    <input
      id={props.id}
      value={props.value || ''}
      onChange={event => props.setState({ value: event.target.value })}
    />
  );
};
```

This ensures the browser-side component state remains available to request-state flows.

## When To Use `assetId` And `/api/internal/javascript`

This path `MAY` be used only when all of these are true:

- a component is loaded lazily after initial bundle execution
- the descriptor includes `isPlugin = $true`
- the descriptor includes `assetId`
- the script returned by `/api/internal/javascript/{assetId}` will call `UniversalDashboard.register(...)`

This path `MUST NOT` be used for:

- the main framework bundle
- CSS delivery
- normal static images, fonts, and icons
- deterministic framework scripts that can be shipped through a published folder

For a full alternate framework, one static published-folder bundle that registers the complete component set up front `SHOULD` be the default design.

## Conformance Checklist

A framework is conforming only if it provides all of the following:

- a way to obtain `dashboardId`, `sessionId`, `pageId`, and API base path
- an HTTP bootstrap call to `/api/internal/dashboard`
- a SignalR connection to `/dashboardhub`
- a `type` to React component registry
- recursive rendering of child descriptors
- `withComponentFeatures` behavior, either by reuse or equivalent reimplementation
- support for websocket messages `setState`, `requestState`, `addElement`, `clearElement`, `removeElement`, `syncElement`, `download`, and `redirect`
- support for HTTP endpoint execution through `/api/internal/component/element/{id}`
- static asset delivery through `.universal/publishedFolders.ps1`

## Suggested Delivery Sequence

1. Start the harness in `Apps/Frameworks/Harness` and host the framework bundle there.
2. Serve a minimal bundle from a published folder or harness-mounted static path.
3. Fetch `/api/internal/dashboard` and render static descriptors.
4. Reuse or reimplement `withComponentFeatures`.
5. Support HTTP endpoint invocation.
6. Support websocket connection and `setState`.
7. Add `requestState`, `download`, and descriptor tree mutation messages.
8. Add optional UX messages such as toast, modal, clipboard, and custom JS invocation.

## Agent Guidance

- Start from the transport contract, not from the current MUI components.
- Treat `withComponentFeatures`, recursive descriptor rendering, and wrapped endpoint callbacks as the compatibility surface for component behavior.
- Treat the websocket message names and payload shapes documented here as the source of truth for browser-side reactions.
- Treat the documented HTTP endpoints and payloads as the source of truth for server communication.
- Use `Apps/Frameworks/Harness` as the default development and Playwright host for framework work.
- Use published folders for the framework's compiled assets unless lazy plugin loading is explicitly needed.
- Do not assume the server will resolve and host your framework bundle automatically; ship the bundle with the module and expose it explicitly through a published folder.
- Assume future agents may only have this document. Keep framework work anchored in the contracts and examples captured here rather than in private implementation details.

If a future implementation needs to diverge from the built-in dashboard shell completely, it `MUST` preserve the HTTP and websocket contracts first. That is the compatibility boundary that keeps PowerShell cmdlets and descriptor generation useful.