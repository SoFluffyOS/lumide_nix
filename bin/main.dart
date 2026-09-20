/// Nix and Nix Flakes language support plugin for Lumide IDE.
library;

import 'package:lumide_api/lumide_api.dart';
import 'package:lumide_nix/lumide_nix.dart';

void main() => NixPlugin().run();

class NixPlugin extends LumidePlugin {
  late final LogService logService;
  late final NixService nixService;
  late final NixLspService lspService;
  late final NixFormatService formatService;
  late final NixStatusBarService statusBarService;

  @override
  Future<void> onActivate(LumideContext context) async {
    logService = LogService(log);
    logService.info('$pluginName plugin activating...');

    nixService = NixService(context, logService);
    lspService = NixLspService(context, logService, nixService);
    formatService = NixFormatService(context, logService, nixService);
    statusBarService = NixStatusBarService(context);

    // Synchronize status bar when active LSP changes
    lspService.onDidChangeServer = statusBarService.update;

    // Detect Nix CLI
    await nixService.init();

    // Initialize LSP language server
    await lspService.init();

    // Register Status Bar Item with NixOS logomark
    await statusBarService.init(lspService.activeServerType);

    // Register Commands
    await context.commands.registerCommand(
      id: cmdNixRestartLsp,
      title: 'Nix: Restart Language Server',
      category: pluginName,
      callback: ([_]) => lspService.restartLsp(),
    );

    await context.commands.registerCommand(
      id: cmdNixSelectLsp,
      title: 'Nix: Select Language Server (nil / nixd)',
      category: pluginName,
      callback: ([args]) => lspService.selectLsp(args),
    );

    await context.commands.registerCommand(
      id: cmdNixFormatFile,
      title: 'Nix: Format File',
      category: pluginName,
      callback: ([_]) => formatService.formatCurrentFile(),
    );

    await context.commands.registerCommand(
      id: cmdNixFlakeCheck,
      title: 'Nix: Flake Check',
      category: pluginName,
      callback: ([_]) async {
        await context.window.showMessage(
          'Running nix flake check...',
          title: pluginName,
        );
        final res = await nixService.flakeCheck();
        if (res.exitCode == 0) {
          await context.window.showMessage(
            'nix flake check passed!',
            title: pluginName,
          );
        } else {
          await context.window.showMessage(
            'nix flake check failed:\n${res.stderr}',
            title: pluginName,
            type: MessageType.error,
          );
        }
      },
    );

    await context.commands.registerCommand(
      id: cmdNixFlakeUpdate,
      title: 'Nix: Flake Update',
      category: pluginName,
      callback: ([_]) async {
        await context.window.showMessage(
          'Running nix flake update...',
          title: pluginName,
        );
        final res = await nixService.flakeUpdate();
        if (res.exitCode == 0) {
          await context.window.showMessage(
            'nix flake update finished successfully.',
            title: pluginName,
          );
        } else {
          await context.window.showMessage(
            'nix flake update failed:\n${res.stderr}',
            title: pluginName,
            type: MessageType.error,
          );
        }
      },
    );

    await context.commands.registerCommand(
      id: cmdNixFlakeShow,
      title: 'Nix: Flake Show',
      category: pluginName,
      callback: ([_]) async {
        final res = await nixService.flakeShow();
        if (res.exitCode == 0) {
          await context.window.showMessage(
            res.stdout.toString(),
            title: 'Nix: Flake Outputs',
          );
        } else {
          await context.window.showMessage(
            'nix flake show failed:\n${res.stderr}',
            title: pluginName,
            type: MessageType.error,
          );
        }
      },
    );

    logService.info('$pluginName plugin activated successfully');
  }

  @override
  Future<void> onDeactivate() async {
    await statusBarService.dispose();
    logService.info('$pluginName plugin deactivated');
  }
}
