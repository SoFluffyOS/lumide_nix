/// Nix runtime and toolchain environment detection service.
library;

import 'package:lumide_api/lumide_api.dart';
import 'package:lumide_nix/src/constants.dart';
import 'package:lumide_nix/src/services/log_service.dart';

class NixService {
  NixService(this._context, this._logger);

  final LumideContext _context;
  final LogService _logger;

  final String _nixExecutable = defaultNixCommand;
  String? _nixVersion;
  bool _hasNix = false;

  String get nixExecutable => _nixExecutable;
  String? get nixVersion => _nixVersion;
  bool get hasNix => _hasNix;

  /// Initializes Nix toolchain detection.
  Future<bool> init() async {
    return checkNix();
  }

  /// Checks if Nix is available and extracts version info.
  Future<bool> checkNix() async {
    try {
      final res = await _context.shell.run(_nixExecutable, ['--version']);
      if (res.exitCode != 0) {
        _hasNix = false;
        _logger.warning('Nix executable returned non-zero code: ${res.stderr}');
        return false;
      }

      _hasNix = true;
      _nixVersion = parseVersion(res.stdout);
      _logger.info('Detected Nix version: $_nixVersion');
      return true;
    } catch (e) {
      _hasNix = false;
      _logger.warning('Failed to execute Nix: $e');
      return false;
    }
  }

  /// Probes whether [command] is executable and available on the system.
  Future<bool> checkExecutable(String command) async {
    try {
      final res = await _context.shell.run(command, ['--version']);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Runs `nix flake check` in the given or root workspace directory.
  Future<ProcessResult> flakeCheck({String? workspaceRoot}) async {
    final root = switch (workspaceRoot) {
      final r? => r,
      _ => await _context.workspace.getRootUri() ?? '',
    };
    return _context.shell.run(
      _nixExecutable,
      ['flake', 'check'],
      workingDirectory: root.isNotEmpty ? root : null,
    );
  }

  /// Runs `nix flake update` in the given or root workspace directory.
  Future<ProcessResult> flakeUpdate({String? workspaceRoot}) async {
    final root = switch (workspaceRoot) {
      final r? => r,
      _ => await _context.workspace.getRootUri() ?? '',
    };
    return _context.shell.run(
      _nixExecutable,
      ['flake', 'update'],
      workingDirectory: root.isNotEmpty ? root : null,
    );
  }

  /// Runs `nix flake show` in the given or root workspace directory.
  Future<ProcessResult> flakeShow({String? workspaceRoot}) async {
    final root = switch (workspaceRoot) {
      final r? => r,
      _ => await _context.workspace.getRootUri() ?? '',
    };
    return _context.shell.run(
      _nixExecutable,
      ['flake', 'show'],
      workingDirectory: root.isNotEmpty ? root : null,
    );
  }

  /// Parses `nix (Nix) 2.18.1` or `nix 2.24.0` into a clean version string.
  static String parseVersion(String rawOutput) {
    final firstLine = rawOutput.split('\n').firstOrNull ?? '';
    final match = RegExp(r'([0-9]+\.[0-9]+(\.[0-9]+)?)').firstMatch(firstLine);
    if (match case final m?) {
      return m.group(1) ?? firstLine.trim();
    }
    return firstLine.trim();
  }
}
