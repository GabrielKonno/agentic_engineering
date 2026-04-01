---
domain: scheduling-temporal
applies_to: appointment booking, calendar features, recurring events, cron jobs, time-based business rules
---

# Scheduling & Temporal Rules

## Inviolable Rules

1. **All timestamps MUST be stored as UTC** — use `TIMESTAMPTZ` (PostgreSQL), `DATETIME` with UTC convention (MySQL), or equivalent. Never store local times in the database.
2. **Timezone identifiers MUST use IANA format** (`America/Sao_Paulo`, `Europe/London`) — never UTC offset strings (`-03:00`) which don't capture DST rules.
3. **Duration and "time from now" calculations MUST use a timezone-aware date library** — never simple arithmetic (`now + 86400` is NOT "tomorrow" during DST transitions).
4. **Date-only fields (birthdays, holidays) MUST be stored as `DATE` type** without timezone component.

## Storage Patterns

| Data Type | Storage Format | Display Conversion |
|-----------|---------------|-------------------|
| Event time | `TIMESTAMPTZ` (UTC) | Convert to user's timezone at display layer |
| User timezone | `VARCHAR` — IANA identifier | Used for conversion: `America/Sao_Paulo` |
| Duration | Integer (seconds or minutes) | Display as `Xh Ym` in user's locale |
| Recurring rule | RRULE string (RFC 5545) or structured fields | Expand occurrences at display/query time |
| Date-only | `DATE` (no timezone) | Display as-is — no timezone conversion |

## DST Transition Safety

### The Two Dangerous Moments
1. **Spring forward (gap):** Clocks skip ahead — 2:00 AM becomes 3:00 AM. Times between 2:00-2:59 DO NOT EXIST.
   - If a recurring event is scheduled at 2:30 AM: use the next valid time (3:00 AM) or the library's gap resolution
   - NEVER silently skip the occurrence — notify or reschedule
2. **Fall back (fold):** Clocks repeat — 1:00-1:59 AM occurs TWICE.
   - If a recurring event is scheduled at 1:30 AM: specify which occurrence (first or second) or use UTC
   - NEVER process the event twice

### Implementation Rules
- Test scheduling logic with dates near DST transitions for the project's target timezones
- "Tomorrow at X" = add 1 calendar day in the user's timezone, then convert to UTC — NOT `+ 86400 seconds`
- "In 1 hour" = add 3600 seconds to UTC timestamp — this IS simple arithmetic (duration, not calendar)
- Week/month boundaries: use the user's locale for "start of week" (Sunday vs Monday)

## Cross-Timezone Operations
- Availability/scheduling: calculate in the provider's timezone, display in the viewer's timezone
- "Business day" calculations: use the entity's local timezone, not server timezone
- Deadline/cutoff comparisons: compare in UTC — convert both sides to UTC before comparing
- "End of day" for a user = 23:59:59 in the USER'S timezone, not server midnight

## Date Boundary Rules
- "Today" queries MUST use the requesting user's timezone to determine day boundaries
- Daily reports/aggregations MUST specify which timezone defines "day" — document the choice
- "This week" / "this month" MUST use the user's locale for boundaries (affects Sunday-start vs Monday-start)

## Temporal Validation
- `created_at` ≤ `updated_at` — enforce at application level
- `start_time` < `end_time` — validate at schema level, not just UI
- Booking/appointment time MUST be in the future — validate against server UTC, not client time
- Minimum duration constraints enforced at schema level (e.g., appointment ≥ 15 minutes)

## Testing Criteria

### REVIEW:
- [ ] Timestamps stored as UTC with timezone-aware column types?
- [ ] Timezone identifier uses IANA format, not UTC offset?
- [ ] Duration calculations use timezone-aware library?
- [ ] DST edge cases considered for recurring events?

### QUERY:
- QUERY: What column types are used for timestamp storage? → expect: TIMESTAMPTZ or equivalent
- QUERY: Is timezone stored alongside user preferences? → expect: IANA identifier field
