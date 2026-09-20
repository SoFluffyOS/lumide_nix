/// Status bar management for the Nix plugin.
library;

import 'package:lumide_api/lumide_api.dart';
import 'package:lumide_nix/src/constants.dart';
import 'package:lumide_nix/src/models/models.dart';
import 'package:lumide_nix/src/utils/utils.dart';

class NixStatusBarService {
  NixStatusBarService(this._context);

  final LumideContext _context;
  String? _iconPath;

  String? get iconPath => _iconPath;

  /// Initializes and registers the Nix status bar item.
  Future<void> init(NixLspServerType activeServerType) async {
    _iconPath = await resolveAssetPath(assetNixLogomark);

    final itemText = switch (_iconPath) {
      final String _ => '',
      _ => 'Nix',
    };

    await _context.statusBar.createItem(
      id: statusBarNixId,
      text: itemText,
      iconPath: _iconPath,
      alignment: 'right',
      priority: 15,
      tooltip: 'Nix Language Support (${activeServerType.label})',
      command: cmdNixSelectLsp,
    );
  }

  /// Updates the status bar item when the active LSP engine changes.
  Future<void> update(NixLspServerType activeServerType) async {
    final itemText = switch (_iconPath) {
      final String _ => '',
      _ => 'Nix',
    };

    await _context.statusBar.updateItem(
      statusBarNixId,
      text: itemText,
      iconPath: _iconPath,
      tooltip: 'Nix Language Support (${activeServerType.label})',
      command: cmdNixSelectLsp,
    );
  }

  /// Removes the status bar item.
  Future<void> dispose() async {
    await _context.statusBar.disposeItem(statusBarNixId);
  }
}
