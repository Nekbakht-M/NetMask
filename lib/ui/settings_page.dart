import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import 'promo.dart';
import 'theme.dart';
import 'widgets.dart';

const appVersion = '1.0.0';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final st = SettingsScope.of(context);
    final s = st.s;
    final c = context.c;

    Widget head(IconData icon, String label) => Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: c.raised, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: c.accent),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
        ]);

    Widget item(Widget child, {bool last = false}) => Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: c.line))),
          child: child,
        );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                Row(children: [
                  IconSquare(
                      icon: Icons.chevron_left,
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Text(s['set'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                ]),
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(children: [
                    item(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      head(Icons.language, s['lang']),
                      const SizedBox(height: 10),
                      Segmented<AppLang>(
                        items: const [(AppLang.tj, 'Тоҷикӣ'), (AppLang.ru, 'Русский'), (AppLang.en, 'English')],
                        value: st.lang,
                        onChanged: st.setLang,
                      ),
                    ])),
                    item(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      head(Icons.dark_mode_outlined, s['theme']),
                      const SizedBox(height: 10),
                      Segmented<bool>(
                        items: [(true, s['dark']), (false, s['light'])],
                        value: st.dark,
                        onChanged: st.setDark,
                      ),
                    ])),
                    item(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      head(Icons.web_asset, s['start']),
                      const SizedBox(height: 10),
                      Segmented<bool>(
                        items: const [(false, 'IPv4'), (true, 'IPv6')],
                        value: st.startOnV6,
                        onChanged: st.setStartOnV6,
                      ),
                    ])),
                    item(
                      Row(children: [
                        Expanded(child: head(Icons.notes, s['extra'])),
                        const SizedBox(width: 8),
                        Switch(
                          value: st.extraAlways,
                          activeThumbColor: c.onAccent,
                          activeTrackColor: c.accent,
                          onChanged: st.setExtraAlways,
                        ),
                      ]),
                      last: true,
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    FieldLabel(s['dev']),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [c.surface, c.raised]),
                        border: Border.all(color: c.line),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundColor: c.accent,
                            child: Text('N',
                                style: TextStyle(
                                    fontFamily: kMono,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: c.onAccent)),
                          ),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Neka', style: TextStyle(fontWeight: FontWeight.w700)),
                            Text('Telegram', style: TextStyle(color: c.fg2, fontSize: 14)),
                          ]),
                        ]),
                        const SizedBox(height: 10),
                        Text(s['devtxt'], style: TextStyle(color: c.fg2, fontSize: 14)),
                        const SizedBox(height: 10),
                        TelegramButton(label: s['order']),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    FieldLabel(s['about']),
                    ResultRow('NetMask', '${s['ver']} $appVersion'),
                    ResultRow(s['created'], 'Neka', last: true),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
