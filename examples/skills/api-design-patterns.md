---
name: api-design-patterns
effort: medium
description: >
  REST API design conventions and patterns. Use when creating new endpoints,
  reviewing API design, or standardizing an existing API.
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
