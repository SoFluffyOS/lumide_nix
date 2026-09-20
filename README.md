# lumide_nix

[![pub package](https://img.shields.io/pub/v/lumide_nix.svg)](https://pub.dev/packages/lumide_nix) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Powered by SoFluffy](https://img.shields.io/badge/Powered%20by-SoFluffy-orange)](https://sofluffy.io)

The official Nix and Nix Flakes extension for [Lumide IDE](https://lumide.dev).

`lumide_nix` provides comprehensive language support, editor diagnostics, code intelligence, and developer tooling for Nix expressions and Nix Flakes in Lumide.

## Features

### ❄️ Language Server Protocol (LSP)
- **Engine Flexibility**: Seamlessly toggle between [`nil`](https://github.com/oxalica/nil) (recommended for Flakes) and [`nixd`](https://github.com/nix-community/nixd) (recommended for NixOS and nixpkgs), or connect to any custom Nix LSP executable.
- **Auto-Detection**: Automatically detects available language servers in your environment (`PATH`).
- **Code Intelligence**: Real-time syntax diagnostics, auto-completions, signature help, document hover documentation, and symbol navigation.
- **Flake Input Evaluation**: Automatic flake input resolution and auto-archiving options.

### ❄️ Nix Flakes Tooling
- **Flake Check**: Validate flake outputs, inputs, and build configurations directly from the editor (`nix flake check`).
- **Flake Update**: Refresh and update `flake.lock` dependencies on demand (`nix flake update`).
- **Flake Show**: Inspect flake targets, outputs, and package structures (`nix flake show`).

### 🛠 Formatting & Code Style
- **Multi-Formatter Support**: Effortlessly format Nix files using `alejandra`, `nixfmt`, `nixpkgs-fmt`, or `nix fmt`.
- **Editor Integration**: Accessible via the Command Palette or automatic format-on-save workflows.

### 🗂 UI & Workspace Integration
- **Interactive Status Bar**: One-click language server switcher anchored right at the status bar with the official NixOS logomark.
- **Declarative File Nesting**: Automatically nests `flake.lock` under `flake.nix`, and `shell.nix` under `default.nix` in the file tree.

## Commands

Access these via the Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`) or the status bar:

| Command ID | Title | Description |
|---|---|---|
| `nix.selectLsp` | **Nix: Select Language Server (nil / nixd)** | Switch between `nil`, `nixd`, auto-detection, or a custom executable |
| `nix.restartLsp` | **Nix: Restart Language Server** | Restart the active Nix language server |
| `nix.formatFile` | **Nix: Format File** | Format the active Nix document using the configured formatter |
| `nix.flakeCheck` | **Nix: Flake Check** | Check flake outputs and dependencies (`nix flake check`) |
| `nix.flakeUpdate` | **Nix: Flake Update** | Update flake lockfile inputs (`nix flake update`) |
| `nix.flakeShow` | **Nix: Flake Show** | Output flake structure and targets (`nix flake show`) |

## Configuration

Customise the extension in your Lumide settings or workspace configuration:

| Setting | Type | Default | Description |
|---|---|---|---|
| `nix.lsp.server` | `string` | `'auto'` | Active LSP engine (`auto`, `nil`, `nixd`, `custom`) |
| `nix.lsp.path` | `filePath` | `''` | Path to a custom Nix LSP executable |
| `nix.formatting.command` | `string` | `'auto'` | Formatter command (`auto`, `nix fmt`, `alejandra`, `nixpkgs-fmt`, `nixfmt`) |

## Requirements & Prerequisites

The extension works with language servers and formatters available in your system `PATH` or Nix environment:

### 1. Language Servers (LSP)

- **`nil`** *(Recommended for Nix Flakes)*:
  ```bash
  # Using Nix profile
  nix profile install nixpkgs#nil

  # Or in NixOS configuration.nix / Home Manager:
  environment.systemPackages = [ pkgs.nil ];
  ```

- **`nixd`** *(Recommended for NixOS & nixpkgs)*:
  ```bash
  # Using Nix profile
  nix profile install nixpkgs#nixd

  # Or in NixOS configuration.nix / Home Manager:
  environment.systemPackages = [ pkgs.nixd ];
  ```

### 2. Formatters (Optional)

Install your preferred formatter into your profile, system packages, or `devShell`:

```bash
# Alejandra
nix profile install nixpkgs#alejandra

# nixfmt (RFC-166)
nix profile install nixpkgs#nixfmt-rfc-style

# nixpkgs-fmt
nix profile install nixpkgs#nixpkgs-fmt
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ by [SoFluffy](https://sofluffy.io).

## Happy Coding 🦊
