import 'package:lumide_nix/src/services/nix_service.dart';
import 'package:test/test.dart';

void main() {
  group('NixService', () {
    test('parses version correctly from nix --version output', () {
      expect(
        NixService.parseVersion('nix (Nix) 2.18.1\n'),
        equals('2.18.1'),
      );
      expect(
        NixService.parseVersion('nix 2.24.0'),
        equals('2.24.0'),
      );
      expect(
        NixService.parseVersion('nix (Nix) 3.0.0pre2023'),
        equals('3.0.0'),
      );
    });
  });
}
