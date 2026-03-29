---
name: nextjs-supabase
effort: medium
description: >
  Stack patterns for Next.js (App Router) + Supabase (PostgreSQL, Auth, RLS, Storage).
  Includes security settings, component patterns, and common pitfalls.
created: example (framework reference template)
derived_from: null
---

# Next.js + Supabase Patterns

## Architecture

- **Rendering**: Server Components by default. `"use client"` only for: event handlers, useState/useEffect, browser APIs.
- **Data fetching**: Server Actions for mutations, server components for reads. No API routes unless needed for webhooks.
- **Auth**: Supabase Auth with SSR middleware. Session refreshed on every request.
- **Database**: Supabase PostgreSQL with RLS. All queries through Supabase client, never raw connections.
- **Storage**: Supabase Storage for file uploads. Bucket policies mirror RLS.

## Key Patterns

### Server Actions
```typescript
"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function createItem(formData: FormData) {
  const supabase = await createClient();
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) return { success: false, error: "Not authenticated" };

  // Get org from membership (never from request body)
  const { data: membership } = await supabase
    .from("organization_members")
    .select("organization_id")
    .eq("user_id", user.id)
    .single();
  if (!membership) return { success: false, error: "No organization" };

  const { data, error } = await supabase
    .from("items")
    .insert({ ...fields, organization_id: membership.organization_id })
    .select()
    .single();

  if (error) return { success: false, error: error.message };
  revalidatePath("/items");
  return { success: true, data };
}
```

### Supabase Client (Server)
```typescript
// src/lib/supabase/server.ts
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options)
          );
        },
      },
    }
  );
}
```

## Security Settings

- [ ] `NEXT_PUBLIC_` vars contain ONLY public-safe values (anon key is OK, service role key is NOT)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` never imported in `src/app/` or `src/components/`
- [ ] Middleware refreshes auth session on every request
- [ ] RLS enabled on ALL business tables
- [ ] RLS policies use `get_user_org_id()` function, never `USING(true)`
- [ ] `next.config.ts` has security headers (CSP, X-Frame-Options, HSTS)
- [ ] Server actions always call `getUser()` before any operation

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Using browser client in server components | Auth state missing, RLS bypassed | Use `createClient()` from `@/lib/supabase/server` |
| Filtering by org_id in queries | Redundant work, risk of wrong org_id | RLS handles filtering — just query without org filter |
| `toISOString()` for dates | Timezone shift (UTC vs local) | Use local date parsing function |
| `dangerouslySetInnerHTML` with user content | XSS vulnerability | React auto-escapes JSX — never bypass |
| Missing `revalidatePath` after mutation | Stale data shown to user | Always call after successful INSERT/UPDATE/DELETE |
| Sequential awaits for independent data | Slow page loads | Use `Promise.all()` for parallel fetching |

## Testing

- Framework: Vitest (not Jest — native ESM + TypeScript)
- Server action tests: mock Supabase client, test business logic
- E2E tests: Playwright for critical user flows
- Test command: `npm test` (add `"test": "vitest"` to package.json)
