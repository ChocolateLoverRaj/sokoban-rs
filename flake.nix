{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # microban.url = "https://www.sourcecode.se/sokoban/download/microban.slc";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # no need to define `system` anymore
        name = "simple";
        src = ./.;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # `eachDefaultSystem` transforms the input, our output set
        # now simply has `packages.default` which gets turned into
        # `packages.${system}.default` (for each system)
        devShells.default =
          let
            pkgs = import nixpkgs {
              inherit system;
            };
          in
          pkgs.mkShell {
            # create an environment with nodejs_18, pnpm, and yarn
            packages = with pkgs; [
              cargo
              clang
              SDL2
              SDL2_image
              SDL2_ttf
            ];
          };
        packages.default =
          let
            inherit (pkgs) stdenv lib;
          in
          stdenv.mkDerivation
            {
              name = "microban";

              src = pkgs.fetchurl {
                url = "https://www.sourcecode.se/sokoban/download/microban.slc";
                sha256 = "sha256-5w4NbGJnBuhmi4nBf7vEQXS9HKLPqlhUwnxZVlnM9Tg=";
              };
              dontUnpack = true;
              installPhase = ''
                mkdir -p $out/share
                cp $src $out/share/microban.slc
              '';
            };
      }
    );
}
