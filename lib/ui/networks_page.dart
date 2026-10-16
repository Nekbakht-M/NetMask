import 'package:flutter/material.dart';

import '../core/ipv4.dart';
import '../services/export.dart';
import 'theme.dart';
import 'widgets.dart';

class NetworksPage extends StatefulWidget {
  const NetworksPage({super.key, required this.ip, required this.prefix});
  final String ip;
  final int prefix;

  @override
  State<NetworksPage> createState() => _NetworksPageState();
}

class _NetworksPageState extends State<NetworksPage> {
  static const _itemExtent = 112.0;
  late final SubnetList _list = allSubnets(widget.ip, widget.prefix);
  late final ScrollController _scroll =
      ScrollController(initialScrollOffset: (_list.currentIndex * _itemExtent - 120).clamp(0, double.infinity));

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _export() {
    final s = SettingsScope.read(context).s;
    final p = widget.prefix;
    final usable = p >= 31 ? 0 : (1 << (32 - p)) - 2;
    shareExcel(
      fileName: 'NetMask_${_list.rows.first.network}_$p.xlsx',
      sheetName: 'NetMask',
      header: ['#', s['c_net'], 'CIDR', s['c_range'], s['c_bc'], s['r_mask'], s['r_usable']],
      rows: [
        for (var i = 0; i < _list.rows.length; i++)
          [
            i + 1,
            _list.rows[i].network,
            '/$p',
            _list.rows[i].hostRange ?? '—',
            _list.rows[i].broadcast,
            maskString(p),
            usable,
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.of(context).s;
    final c = context.c;
    final mono = TextStyle(
      fontFamily: kMono,
      fontFamilyFallback: kMonoFallback,
      fontSize: 13.5,
      height: 1.25,
      color: c.fg,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(children: [
                  IconSquare(
                      icon: Icons.chevron_left,
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.netsTitle(widget.prefix),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                      Text(s.netsSub(_list.rows.length, _list.base),
                          style: TextStyle(fontFamily: kMono, fontSize: 13, color: c.fg2)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  IconSquare(
                    icon: Icons.table_chart_outlined,
                    tooltip: s['xls'],
                    background: AppColors.excel,
                    foreground: Colors.white,
                    onPressed: _export,
                  ),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemExtent: _itemExtent,
                  itemCount: _list.rows.length,
                  itemBuilder: (context, i) {
                    final r = _list.rows[i];
                    final cur = i == _list.currentIndex;
                    Widget line(String k, String v) => Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            SizedBox(
                                width: 70,
                                child: Text(k,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, height: 1.25, color: c.fg2))),
                            Expanded(child: Text(v, style: mono.copyWith(fontSize: 13))),
                          ],
                        );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => copyText(context, '${r.network}/${widget.prefix}'),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cur ? c.accent : c.line),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text('${r.network}/${widget.prefix}',
                                      style: mono.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                                ),
                                Text('#${i + 1}', style: TextStyle(fontSize: 12, color: c.fg2)),
                              ]),
                              const SizedBox(height: 4),
                              line(s['hosts'], r.hostRange ?? '—'),
                              const SizedBox(height: 2),
                              line(s['bc'], r.broadcast),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
