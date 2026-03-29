---
name: e-commerce-patterns
effort: high
description: >
  Test patterns and business rules for e-commerce features: cart, checkout,
  inventory, pricing, discounts, orders, payments, shipping, refunds.
created: example (framework reference template)
derived_from: null
---

# E-Commerce Domain Patterns

## Critical Business Rules

### Cart
- Cart total = SUM(item_price × quantity) for all items — recalculate on every modification
- Adding item with quantity 0 removes it from cart (not error)
- Cart must validate stock availability before checkout (not just at add-to-cart)
- Abandoned carts: items return to available stock after timeout (configurable)

### Pricing & Discounts
- **NEVER apply discounts to already-discounted items** unless explicitly stacking
- Discount order: percentage discounts before fixed amount discounts
- Price displayed = price charged — no hidden fees added at checkout
- Currency: always store as integer cents (not float dollars). Display as formatted string.
- Tax calculation: apply to subtotal after discounts, before shipping

### Inventory
- Stock cannot go negative (CHECK constraint >= 0)
- Stock decremented at order confirmation, not at cart add
- If stock insufficient at checkout: reject order, show which items are unavailable
- Reserved stock (in pending orders) must be released on order cancellation/expiry

### Orders
- Order total is snapshot at creation — does not change if product price changes later
- Order status is a state machine: draft → pending_payment → paid → processing → shipped → delivered
- Each status transition logged with timestamp and actor (user or system)
- Cancellation only allowed before "shipped" — after shipping, use refund flow

### Payments
- Payment amount must match order total exactly — reject partial payments (unless installments)
- Failed payments: order stays in "pending_payment", retry allowed, not auto-cancelled
- Duplicate payment prevention: idempotency key required on payment requests
- Refund amount cannot exceed original payment amount

### Shipping
- Shipping cost calculated from: weight, dimensions, origin, destination, method
- Free shipping threshold: compare against subtotal after discounts
- Shipping status tracked independently from order status

## STRONG Criteria Examples

```
QUERY: Add 3 items to cart (prices: R$10, R$25.50, R$3.99, quantities: 2, 1, 5).
  → SELECT total FROM carts WHERE id = [cart_id]
  → total = 2×10 + 1×25.50 + 5×3.99 = 65.45
  SUCCESS: total matches exactly. FAILURE: any rounding difference > 0.01

QUERY: Apply 10% discount to cart with total R$100.
  → total after discount = R$90.00
  → Apply R$5 fixed coupon after percentage
  → final total = R$85.00
  SUCCESS: discounts applied in correct order. FAILURE: R$85.50 (fixed first) or R$85.00 with wrong intermediate

VERIFY: Add item with stock = 1 to cart. Another user buys last unit.
  → First user proceeds to checkout → expect "Item X is no longer available" error
  → Cart updated to reflect unavailable item
  SUCCESS: checkout blocked, user informed. FAILURE: order created with 0 stock

QUERY: Cancel order in "processing" status.
  → stock_movements table: consumption entries reversed (stock returned)
  → financial_transactions: refund transaction created with correct amount
  → order status = "cancelled", cancelled_at = now(), cancelled_by = user_id
  SUCCESS: all 3 reversals present. FAILURE: any missing reversal
```

## Edge Cases Checklist

- [ ] Zero-price items (free samples, promotional items)
- [ ] Maximum quantity limits per item per order
- [ ] Currency rounding (R$10.00 / 3 items = R$3.33 each, total = R$9.99, where does R$0.01 go?)
- [ ] Discount exceeds subtotal (result should be R$0.00, not negative)
- [ ] Order with mixed availability (some items in stock, some not)
- [ ] Concurrent checkout on last item in stock (race condition)
- [ ] Refund on partially shipped order (only refund unshipped items)
- [ ] Price change between cart and checkout (honor cart price or current price?)
