---
domain: e-commerce
applies_to: cart, checkout, orders, payments, inventory, pricing
---

# E-Commerce Rules

## Monetary Values

1. **Store as integer cents** — `price_cents INTEGER`, never `FLOAT` or `DECIMAL` for currency. R$10.50 = 1050.
2. **Display formatting is UI-only** — `formatCurrency(1050)` → `"R$ 10,50"`. Never store formatted strings.
3. **Rounding: half-up to nearest cent** — R$10.00 / 3 = R$3.34, R$3.33, R$3.33 (first item gets the extra cent).
4. **Discount cannot produce negative total** — if discount > subtotal, total = 0, not negative.

## Cart Rules

- Cart total recalculated on EVERY modification (add, remove, change quantity, apply coupon).
- **Never cache cart total** — always compute from items. Cached totals drift.
- Quantity = 0 removes item. Negative quantity rejected.
- Maximum quantity per item: configurable per product (default: 99).
- Cart items reference product at current price. Price snapshot taken at checkout, not at add-to-cart.

## Stock Rules

- `stock_quantity` has CHECK constraint `>= 0` — database prevents negative stock.
- Stock decremented at **order confirmation**, not at cart add.
- Stock reserved (soft hold) during checkout flow — released after timeout (15 min default).
- Cancel/refund: stock returned via `stock_movement` record (type: 'return'), not by editing original movement.
- Stock movements are append-only — never UPDATE or DELETE a movement. Current stock = SUM of all movements.

## Order Rules

- Order total is a **snapshot** — changing product price after order does not affect existing orders.
- Order items store: `product_id`, `product_name` (snapshot), `unit_price` (snapshot), `quantity`, `line_total`.
- `line_total = unit_price × quantity` — stored, not computed on read (snapshot integrity).
- Order-level discount applied AFTER line totals calculated.
- Tax applied to subtotal after discounts, before shipping.

## Order Status Machine

```
draft → pending_payment → paid → processing → shipped → delivered
  ↓                        ↓        ↓
cancelled              refunded  cancelled (partial refund for unshipped items)
```

### Transition Rules
| From | To | Guard | Side Effects |
|------|----|-------|-------------|
| draft → pending_payment | Payment intent created | Create payment record |
| pending_payment → paid | Payment confirmed (webhook) | Decrement stock, send confirmation email |
| paid → processing | Staff action | Update fulfillment queue |
| processing → shipped | Tracking number added | Send shipping notification |
| shipped → delivered | Carrier confirms OR manual | Send delivery confirmation |
| any (before shipped) → cancelled | User or admin action | Return stock, process refund if paid |
| paid → refunded | Admin action | Return stock, reverse payment |

### Invalid Transitions (must be rejected)
- shipped → draft (can't un-ship)
- delivered → any (terminal state)
- cancelled → any (terminal state)
- pending_payment → shipped (can't skip payment)

## Payment Rules

- Payment amount MUST match order total exactly (no partial payments unless installment plan).
- **Idempotency key required** on payment creation — retry-safe, no duplicate charges.
- Payment status: pending → completed / failed / refunded.
- Refund amount ≤ original payment amount. Partial refunds allowed, tracked cumulatively.
- Failed payment: order stays in `pending_payment`, user retries. Auto-cancel after 24h (configurable).

## Discount Rules

- Discount types: percentage (10% off), fixed amount (R$20 off), buy-X-get-Y.
- Application order: percentage discounts → fixed amount discounts → free items.
- **Never stack** percentage discounts unless explicitly allowed by coupon rules.
- Coupon validation: check expiry, usage limit (global and per-user), minimum order value, applicable products/categories.
- Coupon code: case-insensitive, trimmed. `SAVE10` = `save10` = ` Save10 `.

## Testing

```
QUERY: Cart with items (2×R$10.00, 1×R$25.50, 5×R$3.99).
  → cart_total = 2×1000 + 1×2550 + 5×399 = 6545 cents (R$65.45)
  SUCCESS: exact match. FAILURE: rounding error or float arithmetic.

QUERY: Apply 10% discount to R$100.00 cart, then R$5.00 coupon.
  → After 10%: 9000 cents. After R$5: 8500 cents (R$85.00).
  SUCCESS: R$85.00. FAILURE: R$85.50 (wrong order) or R$85.45 (float).

QUERY: Order confirmed → product price changes from R$10.00 to R$15.00.
  → SELECT unit_price FROM order_items WHERE order_id = [id] → 1000 (original price).
  SUCCESS: snapshot preserved. FAILURE: 1500 (dynamic reference, not snapshot).
```
