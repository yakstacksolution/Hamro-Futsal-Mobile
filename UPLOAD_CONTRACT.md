# Upload contract

The Flutter client sends all attachments as `multipart/form-data` using bytes
captured when the user picks the file. The backend and every reverse proxy in
front of it must use limits compatible with this contract.

## Confirmed production incident (2026-08-20)

The Android device trace for `POST /api/bookings` proves the failing payment
proof was not empty on the client:

- Camera source: **1,927,398 bytes**.
- Optimized JPEG retained by the checkout state: **447,094 bytes**.
- Dio multipart part named `payment_proof`: **447,094 bytes**.
- The API returned no response for 120 seconds, after which the client's
  receive timeout surfaced as a synthetic 504 with no response body.

A separate 163,376-byte media upload reached the same Nginx host and succeeded,
but took about 32 seconds. This points to slow or blocked server-side
storage/image processing. A diagnostic object that later shows the filename
with `size = 0` is being produced after the non-empty body leaves Flutter; it
must not be used as evidence that the picker supplied zero bytes.

The client now rejects zero-length multipart parts at both selection time and
the final HTTP boundary. Debug builds log the endpoint, multipart body length,
field, filename, and part byte count without logging file contents.

## Limits

- Maximum original file size: **10 MB per file**.
- Maximum files in one request: **5**.
- Minimum accepted multipart body size: **64 MB**, including boundaries and
  ordinary form fields.
- Images larger than **1.5 MB** are converted to JPEG and optimized by the
  client before upload. PDF and Word documents are never altered.
- Endpoint-provided capabilities (for example settlement proof types and
  maximum size) override the client defaults.

Configure the application server's per-file limit to at least 10 MB and its
request-body limit to at least 64 MB. Configure the ingress/reverse proxy to the
same or higher values. A lower upstream limit can discard a valid multipart
part and make it appear to application code as a named file with `size = 0`.

For the deployed Nginx + PHP application, verify at minimum:

```nginx
client_max_body_size 64m;
client_body_timeout 120s;
fastcgi_read_timeout 120s;
```

```ini
upload_max_filesize = 10M
post_max_size = 64M
max_input_time = 120
```

These limits are required for large uploads, but they do not explain the
confirmed 447,094-byte booking failure. The booking handler itself must also be
corrected:

1. Validate `payment_proof` and call `isValid()`, `getError()`, and `getSize()`
   before moving or storing its temporary file.
2. Capture size and MIME metadata before `store()`/`move()`. Inspecting the old
   temporary path after moving it can incorrectly report zero or unreadable.
3. Keep database transactions limited to database work. Do not run object
   storage, OCR, image optimization, notifications, or remote HTTP calls while
   holding a transaction open.
4. Queue expensive receipt/image processing and respond to booking creation
   promptly. The current endpoint remains blocked beyond 120 seconds.
5. Log the upload error code and measured size before storage, together with a
   server request ID. Never log the bytes themselves.

A Laravel-style handler should follow this order (adapt it to the backend's
actual framework/version):

```php
$validated = $request->validate([
    'payment_proof' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:10240'],
]);

$proof = $request->file('payment_proof');
if ($proof !== null) {
    if (! $proof->isValid() || ($proof->getSize() ?: 0) <= 0) {
        return response()->json([
            'message' => 'The payment proof could not be read. Please attach it again.',
        ], 422);
    }

    $proofSize = $proof->getSize(); // capture before store/move
    $proofPath = $proof->store('payment-proofs', 'public');
}

// Commit the booking, dispatch expensive work to a queue, then return 201.
```

## Multipart fields

| Flow | Field |
| --- | --- |
| Media library | `media_files[]` (repeated) |
| Booking proof | `payment_proof` |
| Settlement proof | `payment_proof` |
| Expense document | `document` |
| Chat attachments | `files[]` (repeated) |

## Error responses

- Return **413** when the whole request exceeds an infrastructure/body limit.
- Return **422** when an individual file violates type, size, or content
  validation. Include an actionable message under `message`, `detail`, or the
  relevant `errors.<field>` entry.
- Do not translate an infrastructure-discarded file into a generic zero-byte
  validation error. Preserve whether the failure was size, type, or transport
  related so the client can tell the user how to recover.
