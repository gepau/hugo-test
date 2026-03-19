{
  description = "Hugo test flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "hugo-test.com";
          src = self;

          buildPhase = ''
            ${pkgs.hugo}/bin/hugo --minify
          '';

          installPhase = "cp -r public $out";
        };

        apps = rec {
          build = utils.lib.mkApp { drv = pkgs.hugo; };
          serve = utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "hugo-serve" ''
              ${pkgs.hugo}/bin/hugo server -D
            '';
          };
          newpost = utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "new-post" ''
              ${pkgs.hugo}/bin/hugo new content posts/"$1".md
            '';
          };
          default = serve;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            hugo
            nixfmt
          ];
        };
      }
    );
}
