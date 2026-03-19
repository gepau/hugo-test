{
  description = "Hugo test flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    utils.url = "github:numtide/flake-utils";
    hugo-hermit-v2 = {
      url = "github:1bl4z3r/hermit-V2?rev=cff7a3f7ef3bc35a05987e10d65a37ce22e3c376";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      hugo-hermit-v2,
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

          configurePhase = ''
            mkdir -p "themes/hermit-V2l"
            cp -r ${hugo-hermit-v2}/* "themes/hermit-V2l"
          '';

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
          shellHook = ''
            mkdir -p themes
            ln -sn "${hugo-hermit-v2}" "themes/hermit-V2"
          '';
        };
      }
    );
}
