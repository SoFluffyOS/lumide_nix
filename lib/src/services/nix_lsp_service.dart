/// LSP registration and lifecycle management service for Nix.
library;

import 'dart:async';

import 'package:lumide_api/lumide_api.dart';
import 'package:lumide_nix/src/constants.dart';
import 'package:lumide_nix/src/models/models.dart';
import 'package:lumide_nix/src/services/log_service.dart';
import 'package:lumide_nix/src/services/nix_service.dart';
import 'package:lumide_nix/src/utils/utils.dart';

class NixLspService {
  NixLspService(this._context, this._logger, this._nixService);

  final LumideContext _context;
  final LogService _logger;
  final NixService _nixService;

  NixLspServerType _activeServerType = NixLspServerType.auto;
  String _activeCommand = defaultNilCommand;
  List<String> _activeArgs = const [];
  bool _isRegistered = false;

  /// Callback notified whenever the active LSP server type changes.
  Future<void> Function(NixLspServerType activeServer)? onDidChangeServer;

  NixLspServerType get activeServerType => _activeServerType;
  String get activeCommand => _activeCommand;
  bool get isRegistered => _isRegistered;

  /// Initializes and registers the Nix language server.
  Future<bool> init() async {
    final configuredServer = await _context.workspace.getConfiguration(
      configLspServer,
    );
    final serverType = NixLspServerType.fromString(
      configuredServer as String?,
    );

    final resolved = await _resolveLspEngine(serverType);
    if (resolved == null) {
      _logger.warning('No Nix Language Server (nil or nixd) found on system');
      unawaited(
        _context.window.showMessage(
          'No Nix Language Server detected. Syntax diagnostics, completion, and flake inspection are disabled.\n\n'
          'Install nil or nixd to enable full Nix support:\n'
          '• nil (recommended): nix profile install nixpkgs#nil (or add pkgs.nil)\n'
          '• nixd: nix profile install nixpkgs#nixd (or add pkgs.nixd)',
          title: pluginName,
          type: MessageType.warning,
        ),
      );
      return false;
    }

    _activeServerType = resolved.serverType;
    _activeCommand = resolved.command;
    _activeArgs = resolved.args;

    await _registerCurrentLsp();
    return true;
  }

  /// Registers or updates the active LSP server in Lumide.
  Future<void> _registerCurrentLsp() async {
    final initOptions = await _buildInitializationOptions();
    final providerId = switch (_activeServerType) {
      NixLspServerType.nil => lspProviderIdNil,
      NixLspServerType.nixd => lspProviderIdNixd,
      _ => lspProviderIdCustom,
    };

    final resolvedIconPath = await resolveAssetPath(assetNixLogomark);

    await _context.languages.registerLanguageServer(
      id: providerId,
      languageId: nixLanguageId,
      displayName: _activeServerType.label,
      fileExtensions: nixFileExtensions,
      command: _activeCommand,
      args: _activeArgs,
      iconPath: resolvedIconPath,
      initializationOptions: initOptions,
    );

    _isRegistered = true;
    _logger.info(
      'Registered Nix LSP ($_activeCommand) with languageId "$nixLanguageId"',
    );
  }

  /// Restarts the active language server.
  Future<void> restartLsp() async {
    if (!_isRegistered) {
      final success = await init();
      if (!success) return;
    } else {
      await _registerCurrentLsp();
    }
    await _context.window.showMessage(
      'Nix Language Server restarted ($_activeCommand)',
      title: pluginName,
    );
  }

  /// Allows the user to select which LSP server to use.
  Future<void> selectLsp([Map<String, dynamic>? args]) async {
    Map<String, int>? position;
    if (args != null && args.containsKey('position')) {
      if (args['position'] case final Map<dynamic, dynamic> posMap) {
        if (posMap['x'] is num && posMap['y'] is num) {
          position = {
            'x': (posMap['x'] as num).toInt(),
            'y': (posMap['y'] as num).toInt(),
          };
        }
      }
    }

    const items = [
      QuickPickItem(
        label: 'nil',
        tooltip: 'Nix Language Server - Recommended for Flakes',
        payload: 'nil',
      ),
      QuickPickItem(
        label: 'nixd',
        tooltip: 'Nix Language Server - Recommended for NixOS & nixpkgs',
        payload: 'nixd',
      ),
      QuickPickItem(
        label: 'Auto-detect',
        tooltip: 'Detects nil first, then nixd',
        payload: 'auto',
      ),
      QuickPickItem(
        label: 'Custom Executable Path',
        tooltip: 'Specify an explicit path to a Nix LSP server',
        payload: 'custom',
      ),
    ];

    final picked = await _context.window.showQuickPick(
      items,
      placeholder: 'Select Nix Language Server Engine',
      position: position,
    );

    if (picked == null) return;

    final payload = picked.payload as String? ?? picked.label;
    if (payload == 'nil') {
      await _switchLspEngine(NixLspServerType.nil);
    } else if (payload == 'nixd') {
      await _switchLspEngine(NixLspServerType.nixd);
    } else if (payload == 'auto') {
      await _switchLspEngine(NixLspServerType.auto);
    } else if (payload == 'custom') {
      final customPath = await _context.window.showInputBox(
        prompt: 'Enter absolute path to custom Nix LSP executable',
        title: 'Custom Nix LSP Path',
        value: _activeCommand,
      );
      if (customPath case final path? when path.trim().isNotEmpty) {
        await _context.workspace.updateConfiguration(
          configLspPath,
          path.trim(),
        );
        await _context.workspace.updateConfiguration(
          configLspServer,
          NixLspServerType.custom.id,
        );
        await _switchLspEngine(NixLspServerType.custom, path.trim());
      }
    }
  }

  Future<void> _switchLspEngine(
    NixLspServerType targetType, [
    String? customPath,
  ]) async {
    final resolved = await _resolveLspEngine(targetType, customPath);
    if (resolved == null) {
      await _context.window.showMessage(
        'Could not locate executable for ${targetType.label}. Ensure it is installed and on PATH.',
        title: pluginName,
        type: MessageType.error,
      );
      return;
    }

    _activeServerType = resolved.serverType;
    _activeCommand = resolved.command;
    _activeArgs = resolved.args;

    await _context.workspace.updateConfiguration(
      configLspServer,
      targetType.id,
    );
    await _registerCurrentLsp();
    await onDidChangeServer?.call(_activeServerType);

    await _context.window.showMessage(
      'Switched Nix Language Server to ${_activeServerType.label} ($_activeCommand)',
      title: pluginName,
    );
  }

  /// Resolves the engine executable based on preference.
  Future<({NixLspServerType serverType, String command, List<String> args})?>
      _resolveLspEngine(NixLspServerType preference,
          [String? explicitPath]) async {
    final customPath = explicitPath ??
        await _context.workspace.getConfiguration(configLspPath) as String?;

    if (customPath case final path? when path.trim().isNotEmpty) {
      final available = await _nixService.checkExecutable(path.trim());
      if (available) {
        return (
          serverType: NixLspServerType.custom,
          command: path.trim(),
          args: <String>[],
        );
      }
    }

    switch (preference) {
      case NixLspServerType.nil:
        final hasNil = await _nixService.checkExecutable(defaultNilCommand);
        if (hasNil) {
          return (
            serverType: NixLspServerType.nil,
            command: defaultNilCommand,
            args: <String>[],
          );
        }
        return null;

      case NixLspServerType.nixd:
        final hasNixd = await _nixService.checkExecutable(defaultNixdCommand);
        if (hasNixd) {
          return (
            serverType: NixLspServerType.nixd,
            command: defaultNixdCommand,
            args: <String>[],
          );
        }
        return null;

      case NixLspServerType.custom:
        return null;

      case NixLspServerType.auto:
        final hasNil = await _nixService.checkExecutable(defaultNilCommand);
        if (hasNil) {
          return (
            serverType: NixLspServerType.nil,
            command: defaultNilCommand,
            args: <String>[],
          );
        }

        final hasNixd = await _nixService.checkExecutable(defaultNixdCommand);
        if (hasNixd) {
          return (
            serverType: NixLspServerType.nixd,
            command: defaultNixdCommand,
            args: <String>[],
          );
        }

        return null;
    }
  }

  /// Builds server initialization options (formatting, flake settings).
  Future<Map<String, dynamic>> _buildInitializationOptions() async {
    final fmtConfig = await _context.workspace.getConfiguration(
      configFormattingCommand,
    ) as String?;

    final fmtCommand = switch (fmtConfig?.trim()) {
      'nix fmt' => ['nix', 'fmt'],
      'alejandra' => ['alejandra'],
      'nixfmt' => ['nixfmt'],
      'nixpkgs-fmt' => ['nixpkgs-fmt'],
      _ => ['nixfmt'],
    };

    return switch (_activeServerType) {
      NixLspServerType.nil => {
          'nil': {
            'formatting': {'command': fmtCommand},
            'nix': {
              'flake': {
                'autoArchive': true,
                'autoEvalInputs': true,
              },
            },
          },
        },
      NixLspServerType.nixd => {
          'nixd': {
            'formatting': {'command': fmtCommand},
          },
        },
      _ => {
          'formatting': {'command': fmtCommand},
        },
    };
  }
}
