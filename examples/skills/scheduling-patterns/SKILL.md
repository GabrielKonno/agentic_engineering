---
name: scheduling-patterns
effort: high
description: >
  Test patterns and business rules for scheduling features: appointments,
  calendars, availability, recurring events, timezone handling, conflicts.
created: example (framework reference template)
derived_from: null
---

# Scheduling Domain Patterns

## Critical Business Rules

### Availability
- Available slots = business hours MINUS (existing appointments + blocked dates + breaks)
- Slot duration configurable per service/provider (30min, 60min, etc.)
- Buffer time between appointments (cleanup/preparation) — not visible to client
- Provider-specific schedules override default business hours

### Appointments
- Double-booking prevention: server-side check at creation time, not just UI
- Status workflow: scheduled → confirmed → in_progress → completed → (invoiced)
- Cancellation policy: time-based rules (>24h free, <24h fee, <1h no-show)
- Rescheduling = cancel + create new (preserves audit trail)

### Recurring Events
- Recurrence defined by: frequency (daily/weekly/monthly), interval, end condition (date or count)
- Individual occurrences can be modified without affecting series ("this event only")
- Deleting series: option to delete all future, all, or just this occurrence
- Exception dates: specific occurrences skipped (holidays, provider absence)

### Timezone Handling
- **Store all times in UTC** in the database
- **Display in user's local timezone** in the UI
- **Calculate availability in provider's timezone** — a provider in São Paulo (UTC-3) has 9-17 local time
- **Never use `toISOString()` for display** — always convert to local timezone first
- DST transitions: verify slots around clock change dates don't duplicate or disappear

### Conflicts
- Two appointments for same provider at same time = conflict (reject second)
- Resource conflicts: room, equipment also checked for overlapping bookings
- Waitlist: if slot is full, offer next available or add to waitlist
- Concurrent booking: use optimistic locking or serialized check to prevent race condition

## STRONG Criteria Examples

```
VERIFY: Provider has hours 09:00-17:00, service is 60min, buffer is 15min.
  Existing appointment at 10:00-11:00.
  → Available slots: [09:00, 11:15, 12:30, 13:45, 15:00, 16:00]
  → Slot at 11:00 NOT available (buffer until 11:15)
  → Slot at 10:00 NOT available (existing appointment)
  SUCCESS: exactly these slots shown. FAILURE: 11:00 shown (buffer ignored)

QUERY: Create appointment at 14:00 for provider A. Another request for 14:00 arrives simultaneously.
  → Only one appointment created. Second request returns "slot no longer available."
  → SELECT COUNT(*) FROM appointments WHERE provider_id = A AND start_time = '14:00' → exactly 1
  SUCCESS: no double booking. FAILURE: count = 2

VERIFY: Recurring weekly appointment every Monday at 10:00, starting Jan 6, for 4 weeks.
  → Creates occurrences: Jan 6, Jan 13, Jan 20, Jan 27
  → Delete "Jan 13 only" → remaining: Jan 6, Jan 20, Jan 27
  → Series still exists with exception date Jan 13
  SUCCESS: 3 occurrences remain, series intact. FAILURE: entire series deleted

VERIFY: Provider in UTC-3. Client in UTC+1. Appointment at "15:00 provider time."
  → Client sees "19:00" in their calendar
  → Database stores start_time in UTC: "18:00Z"
  SUCCESS: all 3 representations consistent. FAILURE: any timezone mismatch
```

## Edge Cases Checklist

- [ ] Midnight boundary — appointment from 23:30 to 00:30 (crosses day boundary)
- [ ] DST transition — appointment at 02:30 on clock-change day (time may not exist or occur twice)
- [ ] Zero-duration events (reminders, milestones)
- [ ] All-day events (no specific time, just date)
- [ ] Overlapping multi-day events
- [ ] Provider with no availability (all slots blocked)
- [ ] Past date booking (should be rejected or allowed for record-keeping?)
- [ ] Service longer than remaining business hours (last slot of day)
