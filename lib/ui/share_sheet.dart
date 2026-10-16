import 'package:flutter/material.dart';

import '../services/export.dart';
import 'theme.dart';
import 'widgets.dart';

/// Bottom sheet that previews the full result and shares it as text or Excel.
Future<void> showShareSheet(
  BuildContext context, {
  required String title,
  required List<(String, String)> fields,
  required String fileName,
}) {
  final s = SettingsScope.of(context).s;
  final text = '$title\n\n${fields.map((f) => '${f.$1}: ${f.$2}').join('\n')}\n\n— NetMask · ${s['madeby']}';
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = ctx.c;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .85),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.raised,
              border: Border.all(color: c.line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s['shT'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 12),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border.all(color: c.line),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        text,
                        style: TextStyle(
                            fontFamily: kMono,
                            fontFamilyFallback: kMonoFallback,
                            fontSize: 12.5,
                            height: 1.6,
                            color: c.fg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: PrimaryButton(
                      label: s['asText'],
                      icon: Icons.share,
                      onPressed: () => shareText(text, subject: title),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.excel,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.table_chart_outlined, size: 20),
                        label: Text(s['asXls'],
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        onPressed: () => shareExcel(
                          fileName: fileName,
                          sheetName: 'NetMask',
                          header: [s['field'], s['value']],
                          rows: [for (final f in fields) [f.$1, f.$2]],
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: GhostButton(label: s['copy'], onPressed: () => copyText(ctx, text))),
                  const SizedBox(width: 10),
                  Expanded(child: GhostButton(label: s['close'], onPressed: () => Navigator.pop(ctx))),
                ]),
              ],
            ),
          ),
        ),
      );
    },
  );
}
