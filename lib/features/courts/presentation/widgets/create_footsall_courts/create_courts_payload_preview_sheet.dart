import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_footsall_court_payload.dart';

Future<void> showCreateCourtsPayloadPreviewSheet(
  BuildContext context,
  CreateFootsallCourtPayload payload,
) {
  final String prettyJson = const JsonEncoder.withIndent(
    '  ',
  ).convert(payload.toJson());

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: LightColor.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Create Shop Payload',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: LightColor.titleTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Matches the backend schema you shared.',
              style: TextStyle(color: LightColor.darkgrey),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: LightColor.lightGrey),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    prettyJson,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: LightColor.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightColor.skyBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
