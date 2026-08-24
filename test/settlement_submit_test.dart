import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/features/account/data/repositories/account_repository_impl.dart';

UploadAttachment proof({
  String name = 'proof.png',
  List<int> bytes = const <int>[1, 2, 3, 4],
}) => UploadAttachment(
  filename: name,
  bytes: Uint8List.fromList(bytes),
  sourcePath: '/tmp/$name',
);

void main() {
  group('consolidated settlement', () {
    test('sends no venue_id', () {
      final fields = buildSettlementFields(
        amount: 18500,
        transactionReference: 'TXN-SETTLEMENT-001',
        paymentProof: proof(),
        note: 'Consolidated settlement payment proof',
      );
      expect(fields.containsKey('venue_id'), isFalse);
      expect(fields['amount'], '18500');
      expect(fields['transaction_reference'], 'TXN-SETTLEMENT-001');
      expect(fields['note'], 'Consolidated settlement payment proof');
      expect(fields['payment_proof_attachment'], isA<UploadAttachment>());
    });
  });

  group('per-futsal settlement', () {
    test('sends venue_id alongside the same fields', () {
      final fields = buildSettlementFields(
        amount: 11000,
        transactionReference: 'TXN-VENUE-001',
        paymentProof: proof(),
        venueId: 1,
        note: 'Venue settlement payment proof',
      );
      expect(fields['venue_id'], 1);
      expect(fields['amount'], '11000');
      expect(fields['transaction_reference'], 'TXN-VENUE-001');
      expect(fields['note'], 'Venue settlement payment proof');
    });
  });

  test('keeps paisa on a fractional commission', () {
    final fields = buildSettlementFields(
      amount: 1402.52,
      transactionReference: 'TXN-1',
      paymentProof: proof(),
      venueId: 1,
    );
    expect(fields['amount'], '1402.52');
  });

  test('omits an empty note rather than sending a blank one', () {
    expect(
      buildSettlementFields(
        amount: 66,
        transactionReference: 'TXN-2',
        paymentProof: proof(),
        note: '   ',
      ).containsKey('note'),
      isFalse,
    );
    expect(
      buildSettlementFields(
        amount: 66,
        transactionReference: 'TXN-3',
        paymentProof: proof(),
      ).containsKey('note'),
      isFalse,
    );
  });

  test('trims the transaction reference', () {
    expect(
      buildSettlementFields(
        amount: 10,
        transactionReference: '  TXN-4  ',
        paymentProof: proof(),
      )['transaction_reference'],
      'TXN-4',
    );
  });

  group('payment proof', () {
    test('carries the bytes captured at pick time', () {
      final fields = buildSettlementFields(
        amount: 1402.52,
        transactionReference: 'TXN-5',
        paymentProof: proof(name: 'Screenshot_20260818_214247.jpg'),
        venueId: 1,
      );
      final UploadAttachment attachment =
          fields['payment_proof_attachment'] as UploadAttachment;
      expect(attachment.bytes.length, 4);
      expect(
        attachment.filename,
        'Screenshot_20260818_214247.jpg',
        reason: 'the original filename must survive a bytes upload',
      );
    });

    test('does not leak internal path/byte/name keys into API fields', () {
      final fields = buildSettlementFields(
        amount: 100,
        transactionReference: 'TXN-6',
        paymentProof: proof(),
      );
      expect(fields.containsKey('payment_proof_bytes'), isFalse);
      expect(fields.containsKey('payment_proof_name'), isFalse);
      expect(fields.containsKey('payment_proof_path'), isFalse);
      expect(fields['payment_proof_attachment'], isA<UploadAttachment>());
    });
  });
}
