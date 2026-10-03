# Vendor operations dashboard — API contract

The vendor Home tab (`lib/features/vendor_operations/`) is built on today's
endpoints. This document lists what the backend needs to add so the dashboard
can meet its safety and accuracy requirements without client-side workarounds.
Each item says what the app does today and what it will do once the endpoint
exists.

Conventions: times are Asia/Kathmandu wall-clock, `HH:mm`, intervals are
**start-inclusive, end-exclusive** (`18:00–19:00` and `19:00–20:00` do not
overlap). Money is NPR as a decimal number. Every endpoint is scoped to the
authenticated vendor (and, for staff, to the venues they are permitted on);
a court or venue outside that scope returns `403`, never an empty result.

---

## 1. Group booking — `POST /vendor/booking-groups` (required)

**Today:** the app holds each range with `POST /booking-holds`, releases all
holds if any is refused, then calls `POST /bookings` once per court/range and
records partial payment with `collect-due`. A failure between creates can
still leave a partial group; the app reports it per range and retries only the
missing ranges.

**Needed:** one atomic call.

Headers: `Idempotency-Key: <uuid>` — the app generates one per confirmation
attempt and reuses it on retry. The same key with the same body returns the
original result (`200`) instead of creating anything again; the same key with
a different body returns `422`.

```json
{
  "quote_id": "q_7f3a",                 // from §2, optional but recommended
  "customer": { "phone": "98…", "name": "Dibya", "email": null },
  "note": "Paid at counter",
  "source": "manual",                    // set by the server for vendor users
  "items": [
    { "court_id": 14, "date": "2026-09-26", "start_time": "18:00", "end_time": "19:00" },
    { "court_id": 14, "date": "2026-09-26", "start_time": "20:00", "end_time": "21:00" },
    { "court_id": 6,  "date": "2026-09-26", "start_time": "18:00", "end_time": "19:30" }
  ],
  "payment": { "method": "cash", "amount_received": 1500 },
  "price_overrides": [                   // only for permitted staff, §6
    { "item_index": 2, "price": 1000, "reason": "Regular customer" }
  ]
}
```

Server rules:

- One DB transaction. For each court, lock the court (or its date row)
  `FOR UPDATE`, then reject if any active booking or unexpired hold (not held
  by this request) satisfies `existing.start < new.end AND existing.end >
  new.start`. On PostgreSQL an exclusion constraint on
  `(court_id, tsrange(start_at, end_at, '[)'))` for active bookings makes this
  impossible to bypass.
- All items succeed or none do.
- Prices are computed on the server (§2). A submitted total, if any, is
  ignored.
- `amount_received` must be `0 ≤ x ≤ payable`; above payable returns `422`
  unless a credit/change workflow is explicitly requested.
- If the backend requires one booking per venue, create linked bookings under
  one `group_reference` and allocate the payment across them (response shows
  the allocation).
- Each booking item stores its confirmed price breakdown (§2) so later rate
  changes never rewrite it.

`201`:

```json
{
  "group_reference": "GRP-8K2M",
  "bookings": [
    { "id": 481, "booking_code": "BK-…", "venue_id": 1, "court_id": 14,
      "items": [ … ], "total": 2400, "paid": 1500, "balance_due": 900 },
    { "id": 482, "booking_code": "BK-…", "venue_id": 2, "court_id": 6,
      "items": [ … ], "total": 1800, "paid": 0, "balance_due": 1800 }
  ],
  "totals": { "subtotal": 4200, "discount": 0, "fees": 0, "payable": 4200,
              "received": 1500, "balance_due": 2700 }
}
```

`409` — nothing created:

```json
{ "message": "Some slots are no longer available.",
  "conflicts": [ { "item_index": 1, "reason": "booked", "by": "online" } ] }
```

`422` with `code: "price_changed"` — nothing created; `items[]` carries the
revised prices for the vendor to review and resubmit.

## 2. Price quote — `POST /vendor/booking-quotes` (required)

**Today:** the board estimates prices from each court's slot schedule
(band price, weekend/holiday/special-date price). The server's price is only
seen per range, via the hold's `quote`, and the review asks the vendor to
accept any difference.

**Needed:** the same `items[]` as §1 → an itemised breakdown, including
intervals that cross pricing bands.

```json
{
  "quote_id": "q_7f3a", "expires_at": "2026-09-26T18:10:00+05:45",
  "items": [
    { "item_index": 2, "court_id": 6, "start_time": "18:00", "end_time": "19:30",
      "lines": [
        { "from": "18:00", "to": "19:00", "band": "Peak", "rate": 1200, "amount": 1200 },
        { "from": "19:00", "to": "19:30", "band": "Night", "rate": 1400, "amount": 700 }
      ],
      "subtotal": 1900, "discount": 0, "fees": 0, "total": 1900 }
  ],
  "totals": { "subtotal": …, "discount": …, "taxes": [ … ], "payable": … }
}
```

## 3. Operations board — `GET /vendor/operations/board` (recommended)

**Today:** the app lists venues/courts (`/auth/get-venue-courts`, plus
`/auth/court/{id}` for courts listed without a schedule), fetches every page
of `/futsal-bookings?date_filter=day&date=…`, and builds the grid itself.
Other users' **holds are invisible**, and closures/maintenance come only from
the court's saved closed dates.

**Needed:** `?date=2026-09-26&venue_ids[]=1&court_ids[]=14` →

```json
{
  "date": "2026-09-26",
  "venues": [ { "id": 1, "name": "…", "courts": [ {
    "id": 14, "name": "Court 1", "slot_minutes": 60,
    "open": "06:00", "close": "22:00",
    "slots": [
      { "start": "18:00", "end": "19:00", "state": "available", "price": 1200 },
      { "start": "19:00", "end": "20:00", "state": "held",
        "hold": { "expires_at": "…", "by": "online" } },
      { "start": "20:00", "end": "21:00", "state": "booked",
        "booking": { "id": 471, "code": "BK-…", "customer_name": "Dibya",
                     "status": "confirmed", "payment_status": "partial",
                     "balance_due": 600 } },
      { "start": "21:00", "end": "22:00", "state": "blocked", "reason": "maintenance" }
    ] } ] } ]
}
```

`state` ∈ `available | held | booked | blocked | closed`. A live channel
(the existing Reverb `venueSlots` stream per venue) should push changes.

## 4. Summary figures — `GET /vendor/operations/summary?date=` (recommended)

**Today:** bookings, booked/available court-hours, occupancy, booking value
and outstanding are computed on the device from the board. **Payments
collected** cannot be: payments for bookings on other dates are not in the
day's booking list, so the card shows "needs payments API".

**Needed:**

```json
{ "payments_collected": { "gross": 9600, "refunds": 1200, "net": 8400,
                          "by_method": { "cash": 7200, "online": 1200 } } }
```

(Optionally the other figures too, so the server's definitions are the
source of truth.)

## 5. Holds — batch and visibility (required for §3 parity)

- `POST /booking-holds/batch` — all-or-nothing hold of `items[]`, one expiry,
  one token. Replaces the app's hold-then-release loop.
- Holds must expire on the server, and abandoned holds must be released by a
  scheduled job, not only by the client's `DELETE`.
- The board (§3) must report other users' holds with their expiry.

## 6. Price overrides (required before the app offers them)

Only for roles with an explicit permission (e.g. `bookings.override_price`).
Each override stores **actor, reason, original price, revised price,
timestamp**, and appears in the audit log (§9). The app will show the
override control only when the profile carries that permission.

## 7. Cancellation and refunds (phase 2 of the app)

- `POST /bookings/{id}/cancel` with `{ "reason": "…" }`. Today cancellation is
  `DELETE /bookings/{id}` with no body, so no reason can be recorded.
- Refunds are a separate action — `POST /bookings/{id}/refunds` with amount,
  method, reason — and cancellation must never imply a refund.
- Check-in / no-show: `POST /bookings/{id}/check-in`, `POST
  /bookings/{id}/no-show`, if the product supports them.

## 8. Customer lookup — `GET /vendor/customers?phone=98…` (recommended)

Returns known customers (name, phone, email, visit count, outstanding) for the
existing-customer lookup on the booking form.

## 9. Audit history

Record booking creation/edits/reschedules, cancellations, payments, refunds,
price overrides and availability blocks with actor, time, before/after.
`GET /bookings/{id}/audit` for the booking drawer.

## 10. Small changes to existing endpoints

- `GET /futsal-bookings`: accept `venue_ids[]` and `court_ids[]`; return
  `court_id` at the top level; include `group_reference` once §1 exists.
- `POST /bookings` (manual): accept `amount_received` so a partial payment
  does not need a second `collect-due` call; return `booking_code`.
- Staff scoping: vendor staff should see only the venues they are assigned to;
  `/auth/get-venue-courts?purpose=booking` should already honour that.

---

### Tests the backend should cover

- Two concurrent group bookings for the same court/time: exactly one
  succeeds, the other gets `409` with the conflicting item.
- Adjacent intervals (`18:00–19:00`, `19:00–20:00`) both succeed; overlapping
  (`18:00–19:00`, `18:30–19:30`) do not.
- An interval crossing a pricing band is priced per band (§2).
- Partial payment: `amount_received` < payable leaves the right balance;
  > payable is rejected.
- Multi-venue group: all bookings created with one `group_reference`, payment
  allocated, or none created.
- Replaying the same `Idempotency-Key` creates nothing new.
- A court of another vendor in `items[]` returns `403`.
