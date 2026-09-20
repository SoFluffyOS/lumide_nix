/// Constants for the Lumide Nix plugin.
library;

// Plugin Metadata
const pluginId = 'lumide_nix';
const pluginName = 'Nix';
const logPrefix = '❄️ [Nix]';

// Asset Paths
const folderAssets = 'assets';
const assetNixLogo = 'nixos-logo.svg';
const assetNixLogoWhite = 'nixos-logo-white.svg';
const assetNixLogomark = 'nixos-logomark.svg';

// Language IDs & File Extensions
const nixLanguageId = 'nix';
const nixFileExtensions = ['.nix'];

// Default Commands
const defaultNilCommand = 'nil';
const defaultNixdCommand = 'nixd';
const defaultNixCommand = 'nix';

const lspProviderIdNil = 'nix-nil';
const lspProviderIdNixd = 'nix-nixd';
const lspProviderIdCustom = 'nix-custom';

// Configuration Keys
const configLspServer = 'nix.lsp.server';
const configLspPath = 'nix.lsp.path';
const configFormattingCommand = 'nix.formatting.command';

// Commands
const cmdNixRestartLsp = 'nix.restartLsp';
const cmdNixSelectLsp = 'nix.selectLsp';
const cmdNixFlakeCheck = 'nix.flakeCheck';
const cmdNixFlakeUpdate = 'nix.flakeUpdate';
const cmdNixFlakeShow = 'nix.flakeShow';
const cmdNixFormatFile = 'nix.formatFile';

// Status Bar IDs
const statusBarNixId = 'lumide_nix.status';
