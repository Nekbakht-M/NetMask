import 'package:flutter/material.dart';

import '../core/ipv6.dart';
import 'promo.dart';
import 'share_sheet.dart';
import 'theme.dart';
import 'widgets.dart';

class Ipv6View extends StatefulWidget {
  const Ipv6View({super.key});

  @override
  State<Ipv6View> createState() => _Ipv6ViewState();
}

class _Ipv6ViewState extends State<Ipv6View> {
  late final TextEditingController _ip;
  late int _prefix;
  Ipv6Result? _result;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    final st = SettingsScope.read(context);
    _ip = TextEditingController(text: st.lastIp6);
    _prefix = st.lastPrefix6;
    if (parseIpv6(st.lastIp6) != null) _result = Ipv6Result(st.lastIp6, _prefix);
  }

  @override
  void dispose() {
    _ip.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final ip = _ip.text.trim();
    if (parseIpv6(ip) == null) {
      setState(() {
        _error = true;
        _result = null;
      });
      return;
    }
    final st = SettingsScope.read(context);
    setState(() {
      _error = false;
      _result = Ipv6Result(ip, _prefix);
    });
    st.remember6(ip, _prefix);
    if (st.countCalculation()) showPromo(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.of(context).s;
    final c = context.c;
    final r = _result;
    final fields = r == null
        ? const <(String, String)>[]
        : [
            (s['r_ip'], r.ipWithPrefix),
            (s['r6_full'], r.full),
            (s['r6_total'], r.totalAddresses),
            (s['r6_net'], r.network),
            (s['r6_range'], r.range),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s['v6t'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 14),
              FieldLabel(s['pfx']),
              DropdownButtonFormField<int>(
                initialValue: _prefix,
                isExpanded: true,
                dropdownColor: c.raised,
                menuMaxHeight: 420,
                style: TextStyle(
                    fontFamily: kMono, fontSize: 16, fontWeight: FontWeight.w500, color: c.fg),
                items: [
                  for (var p = 128; p >= 1; p--) DropdownMenuItem(value: p, child: Text('/$p')),
                ],
                onChanged: (v) => setState(() => _prefix = v!),
              ),
              const SizedBox(height: 14),
              FieldLabel(s['ip']),
              TextField(
                controller: _ip,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _calculate(),
                onChanged: (_) {
                  if (_error) setState(() => _error = false);
                },
                style: TextStyle(
                    fontFamily: kMono, fontSize: 15, fontWeight: FontWeight.w500, color: c.fg),
                decoration: InputDecoration(
                  hintText: '2001:db8::1',
                  errorText: _error ? s['err'] : null,
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: PrimaryButton(
                        label: s['calc'], icon: Icons.play_arrow_rounded, onPressed: _calculate)),
                const SizedBox(width: 10),
                GhostButton(
                  label: s['clear'],
                  onPressed: () => setState(() {
                    _ip.clear();
                    _result = null;
                    _error = false;
                  }),
                ),
              ]),
            ],
          ),
        ),
        if (r != null) ...[
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < fields.length; i++)
                  ResultRow(fields[i].$1, fields[i].$2,
                      highlight: i == 3, last: i == fields.length - 1),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: s['share'],
                  icon: Icons.share_outlined,
                  onPressed: () => showShareSheet(
                    context,
                    title: 'NetMask · IPv6 · ${r.ipWithPrefix}',
                    fields: fields,
                    fileName: 'NetMask_IPv6_${r.prefix}.xlsx',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
