import 'package:lumide_nix/lumide_nix.dart';
import 'package:test/test.dart';

void main() {
  group('PathUtils', () {
    test('normalizeFilePath handles raw paths and file URIs', () {
      expect(normalizeFilePath('/home/user/flake.nix'), equals('/home/user/flake.nix'));
      expect(
        normalizeFilePath('file:///home/user/flake.nix'),
        equals('/home/user/flake.nix'),
      );
    });

    test('resolveAssetPath resolves nixos-logomark.svg asset', () async {
      final resolved = await resolveAssetPath(assetNixLogomark);
      expect(resolved, isNotNull);
      expect(resolved, endsWith('nixos-logomark.svg'));
    });

    test('resolveAssetPath returns null for non-existent asset', () async {
      final resolved = await resolveAssetPath('non-existent-asset.xyz');
      expect(resolved, isNull);
    });
  });
}
