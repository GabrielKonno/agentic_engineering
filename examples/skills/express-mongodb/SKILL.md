---
name: express-mongodb
effort: medium
description: >
  Stack patterns for Express.js + MongoDB (Mongoose) projects.
  Includes middleware patterns, schema design, security, and API conventions.
created: example (framework reference template)
derived_from: null
---

# Express + MongoDB Patterns

## Architecture

- **Routing**: Express Router with controller separation. Routes define paths, controllers handle logic.
- **Auth**: JWT or session-based. Passport.js for strategies. Auth middleware on protected routes.
- **Database**: MongoDB via Mongoose. Schema validation at model level.
- **Validation**: Joi or Zod for request validation middleware.
- **Error Handling**: Centralized error handler middleware. Async errors caught with wrapper.

## Key Patterns

### Async error wrapper
```javascript
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

router.get("/items", asyncHandler(async (req, res) => {
  const items = await Item.find({ organizationId: req.user.organizationId });
  res.json({ success: true, data: items });
}));
```

### Auth middleware
```javascript
const authenticate = asyncHandler(async (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ error: "No token provided" });

  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  const user = await User.findById(decoded.id).select("-password");
  if (!user) return res.status(401).json({ error: "Invalid token" });

  req.user = user;
  next();
});
```

### Tenant-scoped queries
```javascript
// Middleware: attach org to all queries
const tenantScope = (req, res, next) => {
  req.tenantFilter = { organizationId: req.user.organizationId };
  next();
};

// In controller: always use filter
const getItems = asyncHandler(async (req, res) => {
  const items = await Item.find(req.tenantFilter).sort("-createdAt");
  res.json({ success: true, data: items });
});
```

## Security Settings

```javascript
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const cors = require("cors");

app.use(helmet()); // Security headers
app.use(cors({ origin: process.env.ALLOWED_ORIGINS.split(",") }));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
app.use(express.json({ limit: "10mb" })); // Payload size limit
```

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Missing `await` on Mongoose queries | Returns Query object, not data | Always `await` or use `.exec()` |
| No validation middleware | Invalid data saved to DB | Joi/Zod schema before controller |
| `findById(req.params.id)` without tenant check | Cross-tenant access | Add `.where(req.tenantFilter)` |
| Error details in response | Internal info exposed | Centralized error handler returns generic messages |
| No index on query fields | Slow queries at scale | `schema.index({ organizationId: 1, createdAt: -1 })` |
| Password in JSON response | Credential leak | `.select("-password")` on User queries |

## Testing

- Framework: Jest + Supertest
- Database: mongodb-memory-server for isolated tests
- Test command: `npm test`
- Pattern: `describe("POST /api/items")` → test auth, validation, success, error cases
