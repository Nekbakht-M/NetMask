import 'package:flutter/material.dart';

import '../core/ip_input_formatter.dart';
import '../core/ipv4.dart';
import 'networks_page.dart';
import 'promo.dart';
import 'share_sheet.dart';
import 'theme.dart';
import 'widgets.dart';

class Ipv4View extends StatefulWidget {
  const Ipv4View({super.key});

  @override
  State<Ipv4View> createState() => _Ipv4ViewState();
}

class _Ipv4ViewState extends State<Ipv4View> {
  late final TextEditingController _ip;
  String? _cls = 'C';
  late int _prefix;
  Ipv4Result? _result;
  bool _error = false;
  bool _more = false;

  @override
  void initState() {
    super.initState();
    final st = SettingsScope.read(context);
    _ip = TextEditingController(text: st.lastIp4);
    _prefix = st.lastPrefix4;
    _cls = _prefix >= 24 ? 'C' : _prefix >= 16 ? 'B' : _prefix >= 8 ? 'A' : null;
    if (isValidIpv4(st.lastIp4)) _result = Ipv4Result(st.lastIp4, _prefix);
  }

  @override
  void dispose() {
    _ip.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final ip = _ip.text.trim();
    if (!isValidIpv4(ip)) {
      setState(() {
        _error = true;
        _result = null;
      });
      return;
    }
    final st = SettingsScope.read(context);
    setState(() {
      _error = false;
      _result = Ipv4Result(ip, _prefix);
    });
    st.remember4(ip, _prefix);
    if (st.countCalculation()) showPromo(context);
  }

  List<(String, String)> _fields(Ipv4Result r, bool extra) {
    final s = SettingsScope.of(context).s;
    return [
      (s['r_ip'], r.ip),
      (s['r_net'], r.network),
      (s['r_range'], r.usableRange ?? s['na']),
      (s['r_bc'], r.broadcast),
      (s['r_total'], '${r.totalHosts}'),
      (s['r_usable'], '${r.usableHosts}'),
      (s['r_mask'], r.subnetMask),
      (s['r_wild'], r.wildcard),
      (s['r_bin'], r.binaryMask),
      (s['r_class'], r.ipClass),
      (s['r_cidr'], r.cidr),
      (s['r_type'], r.isPrivate ? s['priv'] : s['pub']),
      (s['r_short'], r.short),
      if (extra) ...[
        ('Binary ID', r.binaryId),
        ('Integer ID', r.integerId),
        ('Hex ID', r.hexId),
        ('in-addr.arpa', r.inAddrArpa),
        ('IPv4 Mapped', r.ipv4Mapped),
        ('6to4 Prefix', r.sixToFour),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final st = SettingsScope.of(context);
    final s = st.s;
    final c = context.c;
    final (lo, _) = prefixRangeForClass(_cls);
    if (_prefix < lo) _prefix = lo;
    final extra = _more || st.extraAlways;
    final r = _result;
    final fields = r == null ? const <(String, String)>[] : _fields(r, extra);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s['v4t'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 14),
              FieldLabel(s['cls']),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final cls in [null, 'A', 'B', 'C'])
                  ChoiceChip(
                    label: Text(cls ?? s['any']),
                    selected: _cls == cls,
                    showCheckmark: false,
                    selectedColor: c.accent,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: _cls == cls ? c.accent : c.line),
                    labelStyle: TextStyle(
                        color: _cls == cls ? c.onAccent : c.fg, fontWeight: FontWeight.w500),
                    shape: const StadiumBorder(),
                    onSelected: (_) => setState(() => _cls = cls),
                  ),
              ]),
              const SizedBox(height: 14),
              FieldLabel(s['sub']),
              DropdownButtonFormField<int>(
                initialValue: _prefix,
                key: ValueKey('sub-$_cls'),
                isExpanded: true,
                dropdownColor: c.raised,
                menuMaxHeight: 420,
                style: TextStyle(
                    fontFamily: kMono, fontSize: 16, fontWeight: FontWeight.w500, color: c.fg),
                items: [
                  for (var p = 32; p >= lo; p--)
                    DropdownMenuItem(value: p, child: Text('${maskString(p)} /$p')),
                ],
                onChanged: (v) => setState(() => _prefix = v!),
              ),
              const SizedBox(height: 14),
              FieldLabel(s['ip']),
              TextField(
                controller: _ip,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [Ipv4InputFormatter()],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _calculate(),
                onChanged: (_) {
                  if (_error) setState(() => _error = false);
                },
                style: TextStyle(
                    fontFamily: kMono, fontSize: 16, fontWeight: FontWeight.w500, color: c.fg),
                decoration: InputDecoration(
                  hintText: '192.168.1.1',
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
                      highlight: i == 1 || i == 3, last: i == fields.length - 1),
                if (!st.extraAlways)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: c.info, padding: EdgeInsets.zero),
                      onPressed: () => setState(() => _more = !_more),
                      icon: Icon(_more ? Icons.expand_less : Icons.expand_more),
                      label: Text(_more ? s['less'] : s['more']),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: SecondaryButton(
                      label: s['all'],
                      icon: Icons.lan_outlined,
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => NetworksPage(ip: r.ip, prefix: r.prefix))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(
                      label: s['share'],
                      icon: Icons.share_outlined,
                      onPressed: () => showShareSheet(
                        context,
                        title: 'NetMask · IPv4 · ${r.short}',
                        fields: fields,
                        fileName: 'NetMask_${r.network}_${r.prefix}.xlsx',
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
