import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class DocumentReader {
  static Future<String> read(PlatformFile file) async {
    final extension = file.extension?.toLowerCase();

    switch (extension) {
      case 'csv':
        return _readCsv(file);

      case 'xlsx':
      case 'xls':
        return _readExcel(file);

      default:
        throw Exception("Formato non supportato");
    }
  }

  static Future<String> _readCsv(PlatformFile file) async {
    final bytes = file.bytes;

    if (bytes == null) {
      throw Exception("File non leggibile");
    }

    return utf8.decode(bytes);
  }

  static Future<String> _readExcel(PlatformFile file) async {
    final Uint8List? bytes = file.bytes;

    if (bytes == null) {
      throw Exception("File non leggibile");
    }

    final excel = Excel.decodeBytes(bytes);

    final buffer = StringBuffer();

    for (final sheetName in excel.tables.keys) {
      buffer.writeln("=== FOGLIO: $sheetName ===");

      final sheet = excel.tables[sheetName]!;

      for (final row in sheet.rows) {
        final values = row.map((cell) {
          if (cell == null) return "";
          return cell.value.toString();
        }).join(" | ");

        buffer.writeln(values);
      }

      buffer.writeln();
    }

    return buffer.toString();
  }
}