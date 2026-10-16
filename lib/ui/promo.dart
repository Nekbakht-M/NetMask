import 'package:flutter/material.dart';

import '../services/export.dart';
import 'theme.dart';
import 'widgets.dart';

/// One-time card after the 10th calculation.
void showPromo(BuildContext context) {
  final st = SettingsScope.read(context);
  final s = st.s;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = ctx.c;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
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
                Text(s['promoT'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                Text(s['promoB'], style: TextStyle(color: c.fg2)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: TelegramButton(label: s['write'])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GhostButton(
                      label: s['never'],
                      height: 46,
                      onPressed: () {
                        st.disablePromo();
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class TelegramButton extends StatelessWidget {
  const TelegramButton({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 46,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.telegram,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontFamily: kSans, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          onPressed: openTelegram,
          child: FittedBox(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const TelegramIcon(),
              const SizedBox(width: 8),
              Text(label),
            ]),
          ),
        ),
      );
}
