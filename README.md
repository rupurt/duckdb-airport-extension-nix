# duckdb-airport-extension-nix

Nix flake for the [DuckDB Airport extension](https://github.com/Query-farm/duckdb-airport-extension)

```nix

```
## Usage

This `duckdb-nix` flake assumes you have already [installed nix](https://determinate.systems/posts/determinate-nix-installer)

### Flake Template

```shell
> nix flake init -t github:rupurt/duckdb-nix#multi
```

### Custom Flake with Overlay

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.duckdb-nix.url = "github:rupurt/duckdb-nix";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    duckdb-nix,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          duckdb-nix.overlay
        ];
      };
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.duckdb-pkgs.v1_2_0
            pkgs.duckdb-airport-extension-pkgs.default
          ];
        };
      });
}
```

## License

`duckdb-airport-extension-nix` is released under the [MIT license](./LICENSE)
