import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const telegramUrl = 'https://t.me/Neka_m';

Future<void> openTelegram() =>
    launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication);

Future<void> shareText(String text, {String? subject}) =>
    SharePlus.instance.share(ShareParams(text: text, subject: subject));

/// Builds an .xlsx with a green header row and opens the Android share sheet.
Future<void> shareExcel({
  required String fileName,
  required String sheetName,
  required List<String> header,
  required List<List<Object>> rows,
}) async {
  final book = xl.Excel.createExcel();
  final defaultSheet = book.getDefaultSheet() ?? 'Sheet1';
  book.rename(defaultSheet, sheetName);
  final sheet = book[sheetName];
  final headStyle = xl.CellStyle(
    bold: true,
    fontColorHex: xl.ExcelColor.white,
    backgroundColorHex: xl.ExcelColor.fromHexString('#FF1D6F42'),
  );
  sheet.appendRow([for (final h in header) xl.TextCellValue(h)]);
  for (var i = 0; i < header.length; i++) {
    sheet
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        .cellStyle = headStyle;
    sheet.setColumnWidth(i, i == 0 ? 8 : 26);
  }
  for (final r in rows) {
    sheet.appendRow([
      for (final v in r) v is int ? xl.IntCellValue(v) : xl.TextCellValue('$v'),
    ]);
  }
  final bytes = book.encode()!;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await SharePlus.instance.share(ShareParams(
    files: [
      XFile(file.path,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    ],
    subject: fileName,
  ));
}
