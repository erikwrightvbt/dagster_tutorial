{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            pyright
            python313
            ruff
            uv
          ];
          nativeBuildInputs = with pkgs; [
            stdenv.cc.cc.lib
          ];
          LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${pkgs.stdenv.cc.cc.lib}/lib";
          shellHook = ''
            uv cache clean
            if [ -d ".venv" ]; then
              source .venv/bin/activate
              uv sync
            else
              uv venv
              source .venv/bin/activate
              uv add dagster dagster-duckdb dagster-webserver pandas pytest setuptools
              uv lock
            fi
          '';
        };
      }
    );
}
