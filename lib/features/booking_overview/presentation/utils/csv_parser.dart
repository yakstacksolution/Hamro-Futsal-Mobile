import 'dart:convert';
import 'dart:typed_data';

List<List<String>> parseCsv(String text) {
  final String source = text.startsWith('﻿') ? text.substring(1) : text;
  final List<List<String>> rows = <List<String>>[];
  List<String> row = <String>[];
  final StringBuffer field = StringBuffer();
  bool inQuotes = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    if (row.length > 1 || row.first.isNotEmpty) rows.add(row);
    row = <String>[];
  }

  for (int i = 0; i < source.length; i++) {
    final String char = source[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < source.length && source[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(char);
      }
    } else if (char == '"') {
      inQuotes = true;
    } else if (char == ',') {
      endField();
    } else if (char == '\n') {
      endRow();
    } else if (char == '\r') {
      if (i + 1 < source.length && source[i + 1] == '\n') i++;
      endRow();
    } else {
      field.write(char);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

List<List<String>> parseCsvBytes(Uint8List bytes) =>
    parseCsv(utf8.decode(bytes, allowMalformed: true));
