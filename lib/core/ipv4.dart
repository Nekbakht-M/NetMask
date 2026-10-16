/// IPv4 subnet math. Values are kept as int (Dart ints are 64-bit on mobile).
library;

const int _full = 0xFFFFFFFF;

final RegExp _v4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');

bool isValidIpv4(String s) {
  final m = _v4.firstMatch(s.trim());
  if (m == null) return false;
  for (var i = 1; i <= 4; i++) {
    final o = m.group(i)!;
    if (int.parse(o) > 255 || o != int.parse(o).toString()) return false;
  }
  return true;
}

int ipv4ToInt(String ip) =>
    ip.trim().split('.').fold(0, (acc, o) => (acc << 8) | int.parse(o));

String intToIpv4(int n) =>
    [24, 16, 8, 0].map((s) => (n >> s) & 0xFF).join('.');

int maskFromPrefix(int p) => p == 0 ? 0 : (_full << (32 - p)) & _full;

String maskString(int p) => intToIpv4(maskFromPrefix(p));

/// Prefix range offered in the dropdown for a network class (null = any).
(int, int) prefixRangeForClass(String? cls) => switch (cls) {
      'A' => (8, 32),
      'B' => (16, 32),
      'C' => (24, 32),
      _ => (1, 32),
    };

String ipv4Class(String ip) {
  final f = int.parse(ip.split('.').first);
  if (f < 128) return 'A';
  if (f < 192) return 'B';
  if (f < 224) return 'C';
  if (f < 240) return 'D';
  return 'E';
}

bool isPrivateIpv4(int n) =>
    (n >= ipv4ToInt('10.0.0.0') && n <= ipv4ToInt('10.255.255.255')) ||
    (n >= ipv4ToInt('172.16.0.0') && n <= ipv4ToInt('172.31.255.255')) ||
    (n >= ipv4ToInt('192.168.0.0') && n <= ipv4ToInt('192.168.255.255'));

String _bin32(int n) => n.toRadixString(2).padLeft(32, '0');

class Ipv4Result {
  Ipv4Result(this.ip, this.prefix);

  final String ip;
  final int prefix;

  late final int ipInt = ipv4ToInt(ip);
  late final int mask = maskFromPrefix(prefix);
  late final int size = 1 << (32 - prefix);
  late final int networkInt = ipInt & mask;
  late final int broadcastInt = networkInt + size - 1;

  String get network => intToIpv4(networkInt);
  String get broadcast => intToIpv4(broadcastInt);
  int get totalHosts => size;
  int get usableHosts => prefix >= 31 ? 0 : size - 2;

  /// null when the subnet has no usable hosts (/31, /32).
  String? get usableRange => usableHosts == 0
      ? null
      : '${intToIpv4(networkInt + 1)} - ${intToIpv4(broadcastInt - 1)}';

  String get subnetMask => intToIpv4(mask);
  String get wildcard => intToIpv4(_full ^ mask);
  String get binaryMask =>
      RegExp(r'.{8}').allMatches(_bin32(mask)).map((m) => m[0]).join('.');
  String get ipClass => ipv4Class(ip);
  String get cidr => '/$prefix';
  bool get isPrivate => isPrivateIpv4(ipInt);
  String get short => '$ip/$prefix';

  String get binaryId => _bin32(ipInt);
  String get integerId => '$ipInt';
  String get _hex => ipInt.toRadixString(16).padLeft(8, '0');
  String get hexId => '0x$_hex';
  String get inAddrArpa => '${ip.split('.').reversed.join('.')}.in-addr.arpa';
  String get ipv4Mapped => '::ffff:${_hex.substring(0, 4)}.${_hex.substring(4)}';
  String get sixToFour => '2002:${_hex.substring(0, 4)}.${_hex.substring(4)}::/48';
}

class SubnetRow {
  const SubnetRow(this.network, this.hostRange, this.broadcast);
  final String network;
  final String? hostRange;
  final String broadcast;
}

class SubnetList {
  const SubnetList(this.base, this.rows, this.currentIndex);

  /// e.g. "192.168.1.*"
  final String base;
  final List<SubnetRow> rows;
  final int currentIndex;
}

/// All subnets of [prefix] inside the enclosing octet boundary of [ip]
/// (same rule as calculator.net: at most 256 rows).
SubnetList allSubnets(String ip, int prefix) {
  final parent = prefix <= 8 ? 0 : 8 * ((prefix - 1) ~/ 8);
  final count = 1 << (prefix - parent).clamp(0, 8);
  final size = 1 << (32 - prefix);
  final n = ipv4ToInt(ip);
  final parentStart = parent == 0 ? 0 : n & maskFromPrefix(parent);
  final octets = ip.split('.');
  final known = parent ~/ 8;
  final base = known == 0
      ? '*.*.*.*'
      : '${octets.take(known).join('.')}${'.*' * (4 - known)}';
  final rows = <SubnetRow>[];
  for (var i = 0; i < count; i++) {
    final net = parentStart + i * size;
    if (net > _full) break;
    final bc = net + size - 1;
    rows.add(SubnetRow(
      intToIpv4(net),
      prefix >= 31 ? null : '${intToIpv4(net + 1)} - ${intToIpv4(bc - 1)}',
      intToIpv4(bc),
    ));
  }
  final cur = ((n - parentStart) ~/ size).clamp(0, rows.length - 1);
  return SubnetList(base, rows, cur);
}
