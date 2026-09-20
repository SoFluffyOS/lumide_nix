/// Supported Nix LSP server types.
library;

/// Represents the supported Nix Language Server implementations.
enum NixLspServerType {
  auto('auto', 'Auto-detect'),
  nil('nil', 'nil (Nix Language Server)'),
  nixd('nixd', 'nixd'),
  custom('custom', 'Custom');

  const NixLspServerType(this.id, this.label);

  final String id;
  final String label;

  /// Returns the identifier string for JSON serialization.
  String toJson() => id;

  /// Parses an identifier into a [NixLspServerType], defaulting to [auto].
  static NixLspServerType fromString(String? raw) {
    if (raw == null) {
      return NixLspServerType.auto;
    }
    return switch (raw.toLowerCase().trim()) {
      'nil' => NixLspServerType.nil,
      'nixd' => NixLspServerType.nixd,
      'custom' => NixLspServerType.custom,
      _ => NixLspServerType.auto,
    };
  }

  /// Returns the default binary name/command for this server type.
  String get defaultCommand {
    return switch (this) {
      NixLspServerType.nil || NixLspServerType.auto => 'nil',
      NixLspServerType.nixd => 'nixd',
      NixLspServerType.custom => '',
    };
  }

  /// Returns the CLI arguments needed for STDIO communication.
  List<String> get defaultArgs {
    return switch (this) {
      NixLspServerType.nil ||
      NixLspServerType.nixd ||
      NixLspServerType.auto ||
      NixLspServerType.custom =>
        const [],
    };
  }
}
