{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { nixpkgs, systems, treefmt-nix, ... }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f
        (import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        })
      );
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs (_: {
        projectRootFile = "flake.nix";
        programs = {
          dart-format.enable = true;
          deadnix.enable = true;
          mdformat.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
        settings.global.excludes = [ ".envrc" ];
      }));
    in
    {
      devShells = eachSystem (pkgs:
        let
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            buildToolsVersions = [ "35.0.1" ];
            platformVersions = [ "36" ];
            abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          };
          androidSdk = androidComposition.androidsdk;
        in
        {
          default = with pkgs; (mkShell.override { stdenv = clangStdenv; }) {
            packages = [
              treefmtEval.${system}.config.build.wrapper
              git
              zenity
            ];

            nativeBuildInputs = [
              cmake
              flutter
              ninja
              pkg-config
            ];

            buildInputs = [
              androidSdk
              gtk3.dev
              jdk23
              xz.dev
            ];

            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            JAVA_HOME = "${jdk23}";
          };
        });
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        treefmt = treefmtEval.${pkgs.system}.config.build.wrapper;
      });
    };
}
