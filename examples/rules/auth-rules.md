---
domain: authentication-authorization
applies_to: all modules with user access, protected resources, role-based features
---

# Authentication & Authorization Rules

## Authentication

1. **Every server-side action/endpoint MUST verify the user's session** before any operation — no exceptions.
2. **Session validation is server-side only** — client-side checks (localStorage token, cookie presence) are UX, not security.
3. **Passwords stored with bcrypt/argon2/scrypt** — never MD5, SHA1, SHA256, or plaintext.
4. **Session tokens: HttpOnly + Secure + SameSite=Lax** — not accessible via JavaScript, not sent on cross-origin requests.
5. **Logout invalidates session server-side** — deleting the client cookie is not enough.

## Authorization Levels

| Level | What it means | How to check |
|-------|---------------|-------------|
| Authenticated | User has a valid session | `getUser()` returns non-null |
| Member | User belongs to the resource's organization | `organization_members` lookup |
| Manager/Admin | User has elevated role in the organization | `role = 'manager'` or `is_org_manager()` |
| Owner | User created or owns the specific resource | `resource.created_by = user.id` |
| System | Automated action (cron, webhook, migration) | Service role key or system user |

## Authorization Rules

- **Check authorization AFTER authentication** — first verify who the user is, then whether they're allowed.
- **Resource ownership verified on every mutation** — user can only UPDATE/DELETE their own resources (or their org's, depending on model).
- **Role checks are server-side** — disabled UI buttons are UX hints, not security boundaries. API must reject.
- **Privilege escalation blocked** — regular user cannot access manager endpoints, manager cannot access system endpoints.
- **No IDOR** (Insecure Direct Object Reference) — accessing `/api/users/123` verifies that the authenticated user has permission to see user 123, not just that 123 exists.

## Permission Patterns

### Simple: role-based
```
if (user.role !== 'manager') return { error: "Unauthorized" };
```

### Moderate: resource ownership
```
const item = await getItem(id);
if (item.organization_id !== user.organization_id) return { error: "Not found" };
// Return 404, not 403 — don't reveal that the resource exists
```

### Complex: attribute-based
```
const canEdit = (
  user.role === 'manager' ||
  (user.role === 'member' && item.created_by === user.id && item.status === 'draft')
);
if (!canEdit) return { error: "Cannot edit this item" };
```

## Password Reset Flow

1. User requests reset → generate cryptographically random token (≥32 bytes).
2. Store token hash (not plaintext) with expiry (1 hour max).
3. Send link with token to verified email.
4. User clicks link → verify token hash + expiry → allow new password.
5. After successful reset: invalidate token, invalidate ALL existing sessions.
6. **Never** reveal whether email exists — "If an account exists, you'll receive an email."

## API Key / Token Rules

- API keys are secrets — treat like passwords (hash in DB, show once on creation).
- Tokens have expiry — short-lived access tokens (15 min) + long-lived refresh tokens (7 days).
- Refresh token rotation — each refresh invalidates the old refresh token.
- Scope-limited — tokens carry minimum permissions needed.

## Testing

```
VERIFY: Access protected endpoint without auth token.
  → Response: 401 Unauthorized. Body contains NO resource data.
  SUCCESS: 401 with generic error. FAILURE: 200 with data (auth bypass).

VERIFY: Access user B's resource with user A's valid token.
  → Response: 404 Not Found (not 403 — don't reveal existence).
  SUCCESS: 404. FAILURE: 200 with user B's data (IDOR vulnerability).

QUERY: After logout, use the same session token for an API request.
  → Response: 401 Unauthorized. Session no longer valid server-side.
  SUCCESS: 401. FAILURE: 200 (session not invalidated server-side).

VERIFY: Submit password reset for non-existent email.
  → Response: 200 with "If an account exists, you'll receive an email."
  → No email sent, no error revealed.
  SUCCESS: same response as valid email. FAILURE: different response (user enumeration).
```
