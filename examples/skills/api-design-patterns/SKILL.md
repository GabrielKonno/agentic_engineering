---
name: api-design-patterns
invocation: inline
effort: medium
description: >
  REST API design conventions — URL structure, response format standardization,
  status code selection, cursor and offset pagination, versioning strategy,
  rate limiting headers, and endpoint security checklist. Consult when creating
  new endpoints, reviewing API contracts, or standardizing response formats
  across modules. Prevents inconsistent API surfaces that break frontend
  integration and complicate versioning.
created: example (framework reference template)
derived_from: null
fixes: []
---

# API Design Patterns

## URL Structure

```
GET    /api/v1/resources          → List (paginated)
GET    /api/v1/resources/:id      → Get one
POST   /api/v1/resources          → Create
PUT    /api/v1/resources/:id      → Full update
PATCH  /api/v1/resources/:id      → Partial update
DELETE /api/v1/resources/:id      → Delete

# Nested resources (parent-child)
GET    /api/v1/orders/:id/items   → List items of order
POST   /api/v1/orders/:id/items   → Add item to order

# Actions (non-CRUD operations)
POST   /api/v1/orders/:id/cancel  → Cancel order (verb as action)
POST   /api/v1/orders/:id/invoice → Generate invoice
```

## Response Format

```json
// Success (single resource)
{ "data": { "id": "uuid", "name": "Item", ... } }

// Success (list)
{
  "data": [{ "id": "uuid", ... }],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Name is required",
    "details": [
      { "field": "name", "message": "Required field", "code": "required" }
    ]
  }
}
```

## Status Codes

| Code | Meaning | When to use |
|------|---------|-------------|
| 200 | OK | GET success, PUT/PATCH success |
| 201 | Created | POST success (include Location header) |
| 204 | No Content | DELETE success |
| 400 | Bad Request | Malformed request (invalid JSON, wrong type) |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not allowed |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource (unique constraint) |
| 422 | Unprocessable Entity | Validation errors (valid JSON, invalid business rules) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server failure (never expose details to client) |

## Pagination

```
GET /api/v1/items?page=2&per_page=20&sort=-created_at&filter[status]=active

Rules:
- Default per_page: 20. Max per_page: 100. Reject > 100.
- Sort: prefix with - for descending. Default: -created_at
- Filters: query params with field names. Validate against allowed fields.
- Always return pagination metadata (total, pages, current page).
- Cursor-based pagination for real-time data (avoid offset on large tables).
```

## Versioning

- URL prefix: `/api/v1/`, `/api/v2/` (simplest, most explicit)
- Breaking changes = new version. Non-breaking additions = same version.
- Deprecation: return `Deprecation` header with sunset date. Keep old version for 6+ months.

## Rate Limiting

```
Headers to include:
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1625097600

Tiers:
- Public endpoints: 60 req/min
- Authenticated endpoints: 300 req/min
- Auth endpoints (login, register, reset): 10 req/min
- Webhook endpoints: 1000 req/min
```

## Security Checklist

- [ ] Auth on every endpoint (except public ones explicitly listed)
- [ ] Input validation before processing (type, length, format)
- [ ] Output filtering (no password hashes, internal IDs, or debug info)
- [ ] CORS restricted to known origins
- [ ] Rate limiting on all public endpoints
- [ ] Idempotency keys on POST (prevent duplicate creates)
- [ ] Request size limits (reject payloads > configured max)

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Inconsistent response wrapper | Frontend needs per-endpoint parsing logic | Always return `{ data }` or `{ error }` — never raw arrays or unwrapped objects |
| 200 for all responses | Client can't distinguish success from failure without parsing body | Use semantic status codes: 201 for created, 422 for validation, 404 for missing |
| Offset pagination on large tables | Slow queries at high page numbers (`OFFSET 10000`) | Switch to cursor-based pagination for datasets > 10k rows |
| Version in header only | Hard to test with browser, hard to link/share | Use URL prefix (`/api/v1/`) — most explicit and cacheable |
| No rate limit on auth endpoints | Brute force attacks on login/reset | Stricter limits on auth (10/min) vs general API (300/min) |
| Error details in production | Stack traces leak internals to attackers | Return generic message in prod, full details only in dev/staging |

## STRONG Criteria Examples

```
REVIEW: New endpoint added to API.
  → Verify: follows URL convention (plural nouns, nested for parent-child)
  → Verify: response uses standard wrapper `{ data }` or `{ data, pagination }`
  → Verify: error responses use `{ error: { code, message } }` format
  SUCCESS: consistent with existing endpoints. FAILURE: custom format or raw response

REVIEW: List endpoint returns paginated data.
  → Verify: pagination metadata present (`page`, `per_page`, `total`, `total_pages`)
  → Verify: `per_page` has max cap (≤100), rejects larger values
  → Verify: default sort specified (typically `-created_at`)
  SUCCESS: pagination complete and bounded. FAILURE: missing metadata or unbounded page size

REVIEW: Endpoint handles invalid input.
  → Send request with missing required field → expect 422 with field-level error details
  → Send request with wrong type → expect 400
  → Send request to non-existent resource → expect 404 (not 500)
  SUCCESS: appropriate status codes per error type. FAILURE: generic 500 or 200 with error in body
```
