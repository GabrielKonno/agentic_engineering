---
domain: frontend-backend-integration
applies_to: fullstack applications with separate frontend and backend, SSR/SSG apps with API layers, SPAs with REST/GraphQL backends
---

# Frontend-Backend Integration Rules

## Inviolable Rules

1. **API response types MUST be a single source of truth** — shared type definitions (TypeScript interfaces, OpenAPI schemas, or GraphQL schemas) drive both frontend consumption and backend responses. No hand-synced duplicated types.
2. **Auth flow MUST be validated end-to-end** — not just token presence on the client. The complete lifecycle (acquisition → storage → refresh → expiry → logout → redirect) must work across the frontend-backend boundary.
3. **Error responses from backend MUST follow a consistent structure** consumable by frontend error boundaries — e.g., `{ error: { code, message, details? } }`. Frontend must never parse unstructured error strings.
4. **Server-rendered content MUST be hydration-safe** — SSR output must match client initial render. No direct usage of browser-only APIs (`window`, `localStorage`, `navigator`) during server rendering.

## API Contract Drift Prevention

### Shared Type Definitions
- TypeScript: shared types in a common package or co-located file imported by both frontend and backend
- OpenAPI/Swagger: generate client types from the spec (do not hand-write)
- GraphQL: codegen types from schema (do not hand-write)
- If no shared type mechanism exists: document the contract explicitly and validate at integration boundary

### Response Shape Validation
- Frontend validates response shape at the API boundary (runtime validation or type narrowing) — do not blindly cast `as SomeType`
- Optional fields declared as optional in the type — do not assume all fields are always present
- Pagination shape consistent: `{ data: T[], meta: { total, page, pageSize } }` or equivalent documented convention

### Breaking Change Detection
- Removing a response field is a breaking change — deprecate before removing
- Changing a field's type is a breaking change — version the endpoint or add a new field
- Adding a new required request field is a breaking change — use optional with defaults
- Renaming fields is a breaking change — add the new name, keep old as alias during migration

## Auth Flow E2E Patterns

### Token Lifecycle
- Token acquisition: login response sets token (cookie or header) — frontend stores securely
- Token refresh: automatic refresh before expiry — do not wait for 401 to refresh
- Token expiry: frontend handles gracefully — redirect to login, preserve intended destination
- Logout: server-side invalidation + client-side cleanup — both must happen

### Protected Route Handling
- Server middleware validates token on every protected request — not just frontend route guards
- Frontend route guards redirect unauthenticated users to login with return URL
- After login, redirect to originally intended page — not always to home/dashboard
- Token absence and token invalidity both result in redirect to login (not error page)

### CORS and Cookie Configuration
- CORS origin matches deployment environment — not hardcoded to `localhost` or wildcard `*`
- Credentials mode (`credentials: 'include'` or equivalent) configured consistently on frontend and backend
- Cookie domain and path match the deployment topology
- SameSite attribute appropriate for the auth flow (Lax for most, None only with Secure for cross-origin)

## Hydration Patterns (SSR/SSG only)

### Data Fetching Consistency
- Data fetched during SSR is passed to client via serialized props — client does not re-fetch on initial render
- Date/time values serialized as ISO strings during SSR — formatted to locale on client only
- User-specific data (preferences, timezone) either fetched server-side via cookie/session or deferred to client

### Browser API Safety
- `window`, `document`, `localStorage`, `sessionStorage`, `navigator` usage guarded with environment check or wrapped in `useEffect` / `onMounted`
- Components that require browser APIs use dynamic import with `ssr: false` or equivalent mechanism
- No conditional rendering based on `typeof window !== 'undefined'` that produces different HTML — causes hydration mismatch

## Cross-Boundary Error Handling

### Backend Error Format
- Consistent error response structure across all endpoints: `{ error: { code: string, message: string, details?: Record<string, string[]> } }`
- HTTP status codes used correctly: 400 (validation), 401 (unauthenticated), 403 (unauthorized), 404 (not found), 409 (conflict), 422 (unprocessable), 500 (server error)
- Validation errors include field-level detail: `{ error: { code: "VALIDATION_ERROR", message: "...", details: { email: ["Invalid format"], name: ["Required"] } } }`
- Internal implementation details (stack traces, SQL errors, internal paths) NEVER exposed in error responses

### Frontend Error Handling
- Global error boundary catches unexpected errors — shows user-friendly message, not stack trace
- API error handler distinguishes: network error (offline/timeout) vs server error (5xx) vs client error (4xx)
- Network errors show retry option — server errors show "try again later" — client errors show specific guidance
- Form validation errors map backend field-level details to inline field messages
- 401 responses trigger auth refresh or redirect — not a generic error page

## Testing Criteria

### REVIEW:
- [ ] Shared type definitions exist and are the single source of truth for API contracts — no duplicated type files?
- [ ] Auth flow covers token refresh and expiry handling — not just initial login?
- [ ] Error boundary exists and handles API error responses with user-friendly messages?
- [ ] Server-rendered content is hydration-safe — no direct usage of `window`/`localStorage` during SSR?
- [ ] CORS configured per environment — not hardcoded to localhost or wildcard `*`?

### QUERY:
- [ ] API response shape matches the TypeScript interface consumed by frontend — no undeclared fields or missing optional markers?
- [ ] Token refresh triggers automatically before expiry — not only after 401 rejection?

### VERIFY:
- [ ] Access protected route without auth → redirect to login with return URL preserved?
- [ ] Trigger backend 500 error → frontend error boundary shows user-friendly message, not raw error?
