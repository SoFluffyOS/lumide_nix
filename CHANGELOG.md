# Changelog

## 1.0.0

- Initial release of Nix and Nix Flakes language support for Lumide IDE.
- Language Server Protocol (LSP) integration supporting `nil` and `nixd`, plus custom server paths.
- Interactive status bar item featuring the official NixOS logomark and anchored quick-pick language server switcher.
- Nix Flake commands (`nix flake check`, `nix flake update`, `nix flake show`).
- Formatting integration supporting `nix fmt`, `alejandra`, `nixpkgs-fmt`, and `nixfmt`.
- Declarative file tree nesting (`flake.lock` under `flake.nix`, `shell.nix` under `default.nix`).
- Official NixOS branding assets bundled for icon theming.
