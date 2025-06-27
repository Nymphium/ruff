{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        ruby = pkgs.ruby;
        rubyPackages = with pkgs.rubyPackages; [
          redcarpet
          rubocop
          yard
          ruby-lsp
        ];

        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = pkgs.mkShellNoCC {
          packages = rubyPackages  ++ [
            ruby

            pkgs.actionlint

            pkgs.nil
            formatter
          ];
        };
      in
      {
        legacyPackages = pkgs;
        inherit formatter devShells;
      }
    );
}
