import 'package:lumide_nix/lumide_nix.dart';
import 'package:test/test.dart';

void main() {
  group('NixLspServerType', () {
    test('parses from strings correctly', () {
      expect(NixLspServerType.fromString('nil'), equals(NixLspServerType.nil));
      expect(
        NixLspServerType.fromString('NIL '),
        equals(NixLspServerType.nil),
      );
      expect(
        NixLspServerType.fromString('nixd'),
        equals(NixLspServerType.nixd),
      );
      expect(
        NixLspServerType.fromString('custom'),
        equals(NixLspServerType.custom),
      );
      expect(
        NixLspServerType.fromString('unknown'),
        equals(NixLspServerType.auto),
      );
      expect(NixLspServerType.fromString(null), equals(NixLspServerType.auto));
    });

    test('provides correct default command and args', () {
      expect(NixLspServerType.nil.defaultCommand, equals('nil'));
      expect(NixLspServerType.nil.defaultArgs, isEmpty);

      expect(NixLspServerType.nixd.defaultCommand, equals('nixd'));
      expect(NixLspServerType.nixd.defaultArgs, isEmpty);

      expect(NixLspServerType.auto.defaultCommand, equals('nil'));
      expect(NixLspServerType.custom.defaultCommand, isEmpty);
    });

    test('serializes to json string ID correctly', () {
      expect(NixLspServerType.nil.toJson(), equals('nil'));
      expect(NixLspServerType.nixd.toJson(), equals('nixd'));
      expect(NixLspServerType.custom.toJson(), equals('custom'));
      expect(NixLspServerType.auto.toJson(), equals('auto'));
    });
  });
}
