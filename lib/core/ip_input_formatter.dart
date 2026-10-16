import 'package:flutter/services.dart';

/// Formats IPv4 input as the user types: dots are inserted automatically,
/// a typed dot is never doubled, and comma/space count as a dot.
String formatIpv4Input(String raw, {required bool adding}) {
  var v = raw
      .replaceAll(RegExp(r'[,\s]'), '.')
      .replaceAll(RegExp(r'[^0-9.]'), '')
      .replaceAll(RegExp(r'\.{2,}'), '.')
      .replaceFirst(RegExp(r'^\.'), '');
  final parts = <String>[];
  var cur = '';
  for (final ch in v.split('')) {
    if (ch == '.') {
      if (parts.length < 3) {
        parts.add(cur);
        cur = '';
      }
      continue;
    }
    final full = cur.length == 3 ||
        cur == '0' ||
        (cur.isNotEmpty && int.parse(cur + ch) > 255);
    if (full) {
      if (parts.length < 3) {
        parts.add(cur);
        cur = ch;
      }
      continue;
    }
    cur += ch;
  }
  var out = [...parts, cur].join('.');
  final canGrow = cur.length < 3 && cur != '0' && int.parse('${cur}0') <= 255;
  if (adding && parts.length < 3 && cur.isNotEmpty && !canGrow) out += '.';
  return out;
}

class Ipv4InputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final adding = newValue.text.length > oldValue.text.length;
    final text = formatIpv4Input(newValue.text, adding: adding);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
