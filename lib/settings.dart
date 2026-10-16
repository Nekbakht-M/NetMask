import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/strings.dart';

/// User preferences, persisted with SharedPreferences.
class Settings extends ChangeNotifier {
  Settings(this._p)
      : lang = AppLang.values.asNameMap()[_p.getString('lang')] ?? AppLang.tj,
        dark = _p.getBool('dark') ?? true,
        startOnV6 = _p.getBool('startV6') ?? false,
        extraAlways = _p.getBool('extra') ?? false,
        calcCount = _p.getInt('calcs') ?? 0,
        promoOff = _p.getBool('promoOff') ?? false,
        lastIp4 = _p.getString('ip4') ?? '192.168.1.1',
        lastPrefix4 = _p.getInt('p4') ?? 24,
        lastIp6 = _p.getString('ip6') ?? '2001:db8:85a3::8a2e:370:7334',
        lastPrefix6 = _p.getInt('p6') ?? 64;

  final SharedPreferences _p;

  AppLang lang;
  bool dark;
  bool startOnV6;
  bool extraAlways;
  int calcCount;
  bool promoOff;
  String lastIp4;
  int lastPrefix4;
  String lastIp6;
  int lastPrefix6;

  S get s => S.of(lang);

  static Future<Settings> load() async =>
      Settings(await SharedPreferences.getInstance());

  void setLang(AppLang v) {
    lang = v;
    _p.setString('lang', v.name);
    notifyListeners();
  }

  void setDark(bool v) {
    dark = v;
    _p.setBool('dark', v);
    notifyListeners();
  }

  void setStartOnV6(bool v) {
    startOnV6 = v;
    _p.setBool('startV6', v);
    notifyListeners();
  }

  void setExtraAlways(bool v) {
    extraAlways = v;
    _p.setBool('extra', v);
    notifyListeners();
  }

  void remember4(String ip, int p) {
    lastIp4 = ip;
    lastPrefix4 = p;
    _p.setString('ip4', ip);
    _p.setInt('p4', p);
  }

  void remember6(String ip, int p) {
    lastIp6 = ip;
    lastPrefix6 = p;
    _p.setString('ip6', ip);
    _p.setInt('p6', p);
  }

  /// Counts a successful calculation; returns true exactly once, on the 10th.
  bool countCalculation() {
    calcCount++;
    _p.setInt('calcs', calcCount);
    return calcCount == 10 && !promoOff;
  }

  void disablePromo() {
    promoOff = true;
    _p.setBool('promoOff', true);
  }
}
