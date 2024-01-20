{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [];
      perSystem = { config, self', pkgs, lib, system, ... }:
        let
          deps = with pkgs; [
            python312Packages.gyp
          ];
        in
        {
          # build artifact
          packages.default = pkgs.stdenv.mkDerivation {
            name = "piex";
            src = ./.;
            nativeBuildInputs = deps;
            # Now do the configure and build with gyp
            configurePhase = ''
              gyp --depth . -f make
            '';
            buildPhase = ''
              make
            '';
            installPhase = ''
              mkdir -p $out
              cp -r ./out/Default/obj.target/* $out/
            '';
          };

          # dev environment
          devShells.default = pkgs.mkShell {
            inputsFrom = [];
            shellHook = ''
            '';
            buildInputs = deps;
            nativeBuildInputs = with pkgs; [
            ];
          };
        };
    };
}


