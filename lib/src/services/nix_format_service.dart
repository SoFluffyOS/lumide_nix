/// Formatter service for Nix documents.
library;

import 'package:lumide_api/lumide_api.dart';
import 'package:lumide_nix/src/constants.dart';
import 'package:lumide_nix/src/services/log_service.dart';
import 'package:lumide_nix/src/services/nix_service.dart';
import 'package:lumide_nix/src/utils/utils.dart';

class NixFormatService {
  NixFormatService(this._context, this._logger, this._nixService);

  final LumideContext _context;
  final LogService _logger;
  final NixService _nixService;

  /// Formats the current active file or given file path.
  Future<void> formatCurrentFile([Object? args]) async {
    final filePath = await _resolveFilePath(args);
    if (filePath == null) {
      await _context.window.showMessage(
        'No Nix file active to format.',
        title: pluginName,
        type: MessageType.warning,
      );
      return;
    }

    if (!filePath.endsWith('.nix')) {
      await _context.window.showMessage(
        'Active file is not a Nix file ($filePath)',
        title: pluginName,
        type: MessageType.warning,
      );
      return;
    }

    final configuredFmt = await _context.workspace.getConfiguration(
      configFormattingCommand,
    ) as String?;

    final tool = await _resolveFormatterTool(configuredFmt);
    if (tool == null) {
      await _context.window.showMessage(
        'No Nix formatter found. Please install alejandra, nixfmt, or nixpkgs-fmt.',
        title: pluginName,
        type: MessageType.warning,
      );
      return;
    }

    try {
      final res =
          await _context.shell.run(tool.command, [...tool.args, filePath]);
      if (res.exitCode == 0) {
        _logger.info('Formatted $filePath using ${tool.command}');
        await _context.window.showMessage(
          'Formatted with ${tool.command}',
          title: pluginName,
        );
      } else {
        _logger.warning('Formatter error: ${res.stderr}');
        await _context.window.showMessage(
          'Formatting failed: ${res.stderr}',
          title: pluginName,
          type: MessageType.error,
        );
      }
    } catch (e) {
      _logger.error('Failed to run formatter', e);
      await _context.window.showMessage(
        'Failed to run formatter: $e',
        title: pluginName,
        type: MessageType.error,
      );
    }
  }

  Future<({String command, List<String> args})?> _resolveFormatterTool(
    String? preferred,
  ) async {
    final candidate = preferred?.trim().toLowerCase();
    if (candidate == 'alejandra') {
      if (await _nixService.checkExecutable('alejandra')) {
        return (command: 'alejandra', args: <String>[]);
      }
    } else if (candidate == 'nixpkgs-fmt') {
      if (await _nixService.checkExecutable('nixpkgs-fmt')) {
        return (command: 'nixpkgs-fmt', args: <String>[]);
      }
    } else if (candidate == 'nixfmt') {
      if (await _nixService.checkExecutable('nixfmt')) {
        return (command: 'nixfmt', args: <String>[]);
      }
    } else if (candidate == 'nix fmt') {
      if (_nixService.hasNix) {
        return (command: 'nix', args: <String>['fmt']);
      }
    }

    // Auto resolution: probe in order
    if (await _nixService.checkExecutable('alejandra')) {
      return (command: 'alejandra', args: <String>[]);
    }
    if (await _nixService.checkExecutable('nixfmt')) {
      return (command: 'nixfmt', args: <String>[]);
    }
    if (await _nixService.checkExecutable('nixpkgs-fmt')) {
      return (command: 'nixpkgs-fmt', args: <String>[]);
    }
    if (_nixService.hasNix) {
      return (command: 'nix', args: <String>['fmt']);
    }

    return null;
  }

  Future<String?> _resolveFilePath(Object? args) async {
    if (args case final String s when s.isNotEmpty) {
      return normalizeFilePath(s);
    }
    if (args case {'context': {'primary': {'path': final String p}}}
        when p.isNotEmpty) {
      return normalizeFilePath(p);
    }
    if (args case {'path': final String p} when p.isNotEmpty) {
      return normalizeFilePath(p);
    }
    if (args case {'uri': final String u} when u.isNotEmpty) {
      return normalizeFilePath(u);
    }
    final activeDoc = await _context.editor.getActiveDocumentUri();
    if (activeDoc case final doc? when doc.isNotEmpty) {
      return normalizeFilePath(doc);
    }
    return null;
  }
}
