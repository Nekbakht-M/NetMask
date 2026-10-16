import 'package:flutter_test/flutter_test.dart';
import 'package:netmask/core/ip_input_formatter.dart';
import 'package:netmask/core/ipv4.dart';
import 'package:netmask/core/ipv6.dart';

void main() {
  group('IPv4 (values checked against calculator.net)', () {
    test('192.168.1.1/30', () {
      final r = Ipv4Result('192.168.1.1', 30);
      expect(r.network, '192.168.1.0');
      expect(r.usableRange, '192.168.1.1 - 192.168.1.2');
      expect(r.broadcast, '192.168.1.3');
      expect(r.totalHosts, 4);
      expect(r.usableHosts, 2);
      expect(r.subnetMask, '255.255.255.252');
      expect(r.wildcard, '0.0.0.3');
      expect(r.binaryMask, '11111111.11111111.11111111.11111100');
      expect(r.ipClass, 'C');
      expect(r.cidr, '/30');
      expect(r.isPrivate, isTrue);
      expect(r.short, '192.168.1.1/30');
      expect(r.binaryId, '11000000101010000000000100000001');
      expect(r.integerId, '3232235777');
      expect(r.hexId, '0xc0a80101');
      expect(r.inAddrArpa, '1.1.168.192.in-addr.arpa');
      expect(r.ipv4Mapped, '::ffff:c0a8.0101');
      expect(r.sixToFour, '2002:c0a8.0101::/48');
    });

    test('edge prefixes', () {
      expect(Ipv4Result('10.20.30.40', 8).usableRange, '10.0.0.1 - 10.255.255.254');
      expect(Ipv4Result('172.16.5.4', 20).network, '172.16.0.0');
      expect(Ipv4Result('172.16.5.4', 20).broadcast, '172.16.15.255');
      expect(Ipv4Result('8.8.8.8', 32).usableHosts, 0);
      expect(Ipv4Result('8.8.8.8', 32).usableRange, isNull);
      expect(Ipv4Result('8.8.8.8', 31).totalHosts, 2);
      expect(Ipv4Result('8.8.8.8', 1).network, '0.0.0.0');
      expect(Ipv4Result('200.1.1.1', 1).broadcast, '255.255.255.255');
      expect(Ipv4Result('8.8.8.8', 24).isPrivate, isFalse);
    });

    test('validation', () {
      expect(isValidIpv4('192.168.1.1'), isTrue);
      expect(isValidIpv4('256.1.1.1'), isFalse);
      expect(isValidIpv4('192.168.1'), isFalse);
      expect(isValidIpv4('01.2.3.4'), isFalse);
      expect(isValidIpv4('a.b.c.d'), isFalse);
    });

    test('all subnets', () {
      final l = allSubnets('192.168.1.1', 30);
      expect(l.base, '192.168.1.*');
      expect(l.rows.length, 64);
      expect(l.rows.first.network, '192.168.1.0');
      expect(l.rows.last.broadcast, '192.168.1.255');
      expect(l.currentIndex, 0);
      final m = allSubnets('10.1.40.3', 20);
      expect(m.base, '10.1.*.*');
      expect(m.rows.length, 16);
      expect(m.currentIndex, 2);
      expect(allSubnets('10.1.2.3', 8).rows.length, 256);
      expect(allSubnets('10.1.2.3', 32).rows.first.hostRange, isNull);
    });
  });

  group('IPv6', () {
    test('calculator.net example /64', () {
      final r = Ipv6Result('2001:db8:85a3::8a2e:370:7334', 64);
      expect(r.ipWithPrefix, '2001:db8:85a3::8a2e:370:7334/64');
      expect(r.full, '2001:0db8:85a3:0000:0000:8a2e:0370:7334');
      expect(r.totalAddresses, '18,446,744,073,709,551,616');
      expect(r.network, '2001:0db8:85a3:0000::');
      expect(r.range,
          '2001:0db8:85a3:0000:0000:0000:0000:0000 - 2001:0db8:85a3:0000:ffff:ffff:ffff:ffff');
    });
    test('parsing', () {
      expect(parseIpv6('::1'), BigInt.one);
      expect(parseIpv6('1:2:3'), isNull);
      expect(parseIpv6('1::2::3'), isNull);
      expect(parseIpv6('gggg::1'), isNull);
      expect(Ipv6Result('::1', 128).totalAddresses, '1');
    });
  });

  group('IPv4 input auto-dots', () {
    String type(String keys) {
      var acc = '';
      for (final c in keys.split('')) {
        acc = formatIpv4Input(acc + c, adding: true);
      }
      return acc;
    }

    test('typing', () {
      expect(type('192.168.1.1'), '192.168.1.1');
      expect(type('192168'), '192.168.');
      expect(type('10.0.0.1'), '10.0.0.1');
      expect(type('172,16,5,4'), '172.16.5.4');
      expect(type('255255255255'), '255.255.255.255');
      expect(type('26'), '26.');
      expect(formatIpv4Input('192.168.', adding: false), '192.168.');
    });
  });
}
