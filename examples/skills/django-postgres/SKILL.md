---
name: django-postgres
invocation: inline
effort: medium
description: >
  Reference patterns for Django + PostgreSQL projects — model design with tenant
  isolation, manager-level query scoping, class-based view permission checks,
  and middleware security. Consult when implementing models, views, or middleware
  that touch data isolation or access control. Covers 6 pitfalls including N+1
  queries and unscoped querysets.
created: example (framework reference template)
derived_from: null
fixes: []
---

# Django + PostgreSQL Patterns

## Architecture

- **Views**: Class-Based Views for CRUD, Function-Based Views for custom logic
- **Auth**: Django's built-in auth system. `login_required` / `permission_required` on all views.
- **Database**: PostgreSQL via Django ORM. Raw SQL only when ORM is insufficient (complex aggregations).
- **API**: Django REST Framework for API endpoints. Serializers validate all input.
- **Tasks**: Celery for background jobs (email, reports, heavy computation).

## Key Patterns

### Model with multi-tenancy
```python
class TenantModel(models.Model):
    """Base model for all tenant-scoped data."""
    organization = models.ForeignKey(
        "organizations.Organization",
        on_delete=models.CASCADE,
        related_name="%(class)s_set"
    )

    class Meta:
        abstract = True

    def save(self, *args, **kwargs):
        if not self.organization_id:
            raise ValueError("organization_id is required")
        super().save(*args, **kwargs)
```

### Manager with tenant filtering
```python
class TenantManager(models.Manager):
    def for_org(self, organization_id):
        return self.filter(organization_id=organization_id)
```

### View with permission check
```python
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin

class ItemUpdateView(LoginRequiredMixin, UserPassesTestMixin, UpdateView):
    model = Item

    def test_func(self):
        item = self.get_object()
        return item.organization_id == self.request.user.active_organization_id
```

## Security Settings

```python
# settings/production.py
DEBUG = False
ALLOWED_HOSTS = ["yourdomain.com"]
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "DENY"
```

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| N+1 queries in templates | Slow page load, many DB queries | Use `select_related()` / `prefetch_related()` |
| Missing `organization_id` filter | Cross-tenant data leak | Use `TenantManager.for_org()` everywhere |
| Raw SQL with string formatting | SQL injection | Use parameterized queries: `cursor.execute(sql, [param])` |
| `DEBUG = True` in production | Stack traces visible to users | Environment-based settings files |
| Signals without error handling | Silent failures, broken flows | Wrap signal handlers in try/except, log errors |
| Missing migration after model change | Schema drift between environments | Always run `makemigrations` after model changes |

## Testing

- Framework: pytest + pytest-django
- Factory: factory_boy for test data
- Test command: `pytest` or `python manage.py test`
- Coverage: `pytest --cov=apps/ --cov-report=term-missing`

## STRONG Criteria Examples

```
REVIEW: New view accesses model data.
  → Verify: queryset filtered through manager with tenant scoping (not `Model.objects.all()`)
  → Verify: view has `permission_classes` or `LoginRequiredMixin` — not unprotected
  SUCCESS: scoped + authenticated. FAILURE: unscoped queryset or missing permission check

REVIEW: New model created.
  → Verify: has `organization` ForeignKey field
  → Verify: custom manager with `get_queryset().filter(organization=current_org)`
  → Verify: `unique_together` constraints include organization scope
  SUCCESS: tenant-aware model. FAILURE: missing org field or global uniqueness

VERIFY: ORM query in view returns data.
  → Check Django Debug Toolbar or `connection.queries`: N+1 detection
  → Verify: related objects loaded via `select_related()` or `prefetch_related()`
  SUCCESS: ≤2 queries for list view. FAILURE: query count grows with result count
```
