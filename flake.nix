{
  description = "Nix flake for the DuckDB Airport extension";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    duckdb-nix = {
      url = "github:rupurt/duckdb-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    duckdb-src = {
      url = "github:duckdb/duckdb";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    duckdb-nix,
    duckdb-src,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          duckdb-nix.overlay
          self.overlay
        ];
      };
    in {
      # packages exported by the flake
      packages = rec {
        duckdb-airport-extension = pkgs.stdenv.mkDerivation rec {
          pname = "duckdb-airport-extenion";
          version = "v0.0.0";
          src = pkgs.fetchFromGitHub {
            owner = "Query-farm";
            repo = "duckdb-airport-extension";
            # rev = "2e6425d132fbd98f66160495d9445ddf1a12f818";
            # sha256 = "sha256-wN3gQhHjk5WSNhln9Grv+7XjHLhMgqCtDTzLn6fNglQ=";
            rev = "9b8076d2983fed03bc3e6772749d94c27f48505b";
            sha256 = "sha256-wN3gQhHjk5WSNhln9Grv+7XjHLhMgqCtDTzLn6fNglQ=";
            # sha256 = pkgs.lib.fakeHash;
            fetchSubmodules = true;
          };

          nativeBuildInputs = [
            pkgs.cmake
            # pkgs.ninja
            pkgs.pkg-config
            pkgs.python312
            pkgs.vcpkg
          ];

          buildInputs = [
            pkgs.arrow-cpp
            pkgs.boost
            pkgs.curl
            pkgs.msgpack-cxx
            pkgs.duckdb-pkgs.v1_2_0-dev
          ];

          cmakeFlags = [
            "-DEXTENSION_STATIC_BUILD=1"
            # "-DDUCKDB_EXTENSION_CONFIGS=${duckdb-src}/.github/config/out_of_tree_extensions.cmake"
            # "-DDUCKDB_EXTENSION_CONFIGS=${duckdb-src}/.github/config"
            # "-DDUCKDB_EXTENSION_CONFIGS=${duckdb-src}/.github/config"
            "-DVCPKG_TOOLCHAIN_PATH=${src}/vcpkg/scripts/buildsystems/vcpkg.cmake"
          ];

          # configurePhase = ''
          #   echo 'ls -l $src'
          #   echo $src
          #   ls -l $src
          #   echo 'ls -l $src/duckdb'
          #   ls -l $src/duckdb
          #   echo 'ls -l $src/extension-ci-tools'
          #   ls -l $src/extension-ci-tools
          #   # echo 'ls -l $src/vcpkg'
          #   # ls -l $src/vcpkg
          #   # echo 'ls -l $duckdb-src'
          #   # ls -l ${duckdb-src}
          #   # exit 1
          #
          #   # # ${src}/vcpkg/bootstrap-vcpkg.sh
          #   # # ${src}/scripts/bootstrap-template.py
          #   # ls -l ${src}/scripts/bootstrap-template.py
          #   # python3 scripts/bootstrap-template.py ext_1_a_123b_b11
          # '';
        };
        default = duckdb-airport-extension;
      };

      # nix fmt
      formatter = pkgs.alejandra;

      # dev shell
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.vcpkg
          pkgs.duckdb-pkgs.v1_2_0-dev
          # pkgs.duckdb-airport-extension-pkgs.default
        ];
      };
    });
  in
    outputs
    // {
      # Overlay that can be imported so you can access the packages
      # using duckdb-nix.overlay
      overlay = final: prev: {
        duckdb-airport-extension-pkgs = outputs.packages.${prev.system};
      };
    };
}
