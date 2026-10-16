/// IPv6 subnet math with BigInt.
library;

final RegExp _group = RegExp(r'^[0-9a-f]{1,4}$');

BigInt? parseIpv6(String input) {
  final s = input.trim().toLowerCase();
  if (s.isEmpty || !RegExp(r'^[0-9a-f:]+$').hasMatch(s)) return null;
  if ('::'.allMatches(s).length > 1) return null;
  List<String> groups;
  if (s.contains('::')) {
    final parts = s.split('::');
    final a = parts[0].isEmpty ? <String>[] : parts[0].split(':');
    final b = parts[1].isEmpty ? <String>[] : parts[1].split(':');
    final fill = 8 - a.length - b.length;
    if (fill < 1) return null;
    groups = [...a, ...List.filled(fill, '0'), ...b];
  } else {
    groups = s.split(':');
  }
  if (groups.length != 8 || groups.any((g) => !_group.hasMatch(g))) return null;
  return groups.fold<BigInt>(
      BigInt.zero, (acc, g) => (acc << 16) + BigInt.parse(g, radix: 16));
}

String fullIpv6(BigInt n) {
  final hex = n.toRadixString(16).padLeft(32, '0');
  return [for (var i = 0; i < 32; i += 4) hex.substring(i, i + 4)].join(':');
}

String _thousands(BigInt n) {
  final s = n.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

class Ipv6Result {
  Ipv6Result(this.input, this.prefix) : value = parseIpv6(input)!;

  final String input;
  final int prefix;
  final BigInt value;

  late final BigInt _size = BigInt.one << (128 - prefix);
  late final BigInt _network = (value >> (128 - prefix)) << (128 - prefix);

  String get ipWithPrefix => '${input.trim()}/$prefix';
  String get full => fullIpv6(value);
  String get totalAddresses => _thousands(_size);

  /// Network shown like calculator.net: the groups covered by the prefix, then "::".
  String get network {
    final groups = fullIpv6(_network).split(':');
    final keep = (prefix + 15) ~/ 16;
    return groups.take(keep).join(':') + (keep < 8 ? '::' : '');
  }

  String get rangeStart => fullIpv6(_network);
  String get rangeEnd => fullIpv6(_network + _size - BigInt.one);
  String get range => '$rangeStart - $rangeEnd';
}
