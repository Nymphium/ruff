{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    flake-utils.url = "github:numtide/flake-utils";
    bundix = {
      url = "github:inscapist/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ruby-nix = {
      url = "github:inscapist/ruby-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ruby-nix,
      bundix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        initRuby = pkgs.ruby;
        rubyNix = (ruby-nix.lib pkgs) {
          ruby = initRuby;
          gemset = ./gemset.nix;
        };
        bundix' = pkgs.callPackage bundix {
          ruby = initRuby;
        };

        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = pkgs.mkShellNoCC {
          packages = [
            rubyNix.ruby
            rubyNix.env

            pkgs.actionlint

            pkgs.nil
            formatter
          ];
        };
      in
      {
        legacyPackages = pkgs;
        apps.bundix = {
          program = "${bundix'}/bin/bundix";
          type = "app";
        };

        inherit formatter devShells;
      }
    );
}
