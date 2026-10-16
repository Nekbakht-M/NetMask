import 'package:flutter/material.dart';

import 'ipv4_view.dart';
import 'ipv6_view.dart';
import 'settings_page.dart';
import 'theme.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _v6 = SettingsScope.read(context).startOnV6;

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.of(context).s;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset('assets/brand/icon.png', width: 34, height: 34),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('NetMask',
                          style: TextStyle(fontFamily: kMono, fontWeight: FontWeight.w700, fontSize: 19)),
                    ),
                    IconSquare(
                      icon: Icons.settings_outlined,
                      tooltip: s['set'],
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const SettingsPage())),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Segmented<bool>(
                    mono: true,
                    items: const [(false, 'IPv4'), (true, 'IPv6')],
                    value: _v6,
                    onChanged: (v) => setState(() => _v6 = v),
                  ),
                  const SizedBox(height: 14),
                  Offstage(offstage: _v6, child: const Ipv4View()),
                  Offstage(offstage: !_v6, child: const Ipv6View()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
