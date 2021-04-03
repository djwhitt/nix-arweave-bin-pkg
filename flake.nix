{
  description = "Arweave Server flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = flake-utils.lib.flattenTree {
          arweave-bin =
            let
              p = { stdenv, lib, fetchurl, autoPatchelfHook, zlib, gmp, openssl, ncurses, ... }: pkgs.stdenv.mkDerivation rec {
                name = "arweave-bin";
                version = "2.4.1.0";

                src = fetchurl {
                  url = "https://github.com/ArweaveTeam/arweave/releases/download/N.${version}/arweave-${version}.centos8-ubuntu20-x86_64.tar.gz";
                  sha256 = "sha256-SxHz1y0/Hph+HvEmujjyHZHo/tDP/XFByGRoJfZ6Sss=";
                };

                nativeBuildInputs = [
                  autoPatchelfHook
                  stdenv.cc.cc.lib
                  gmp
                  ncurses
                  openssl
                  zlib
                ];

                unpackPhase = ''
                  tar xvf $src
                '';

                installPhase = ''
                  mkdir -p $out/arweave
                  mv * $out/arweave
                '';

                meta = with lib; {
                  homepage = https://github.com/ArweaveTeam/arweave;
                  description = "Arweave Server.";
                  platforms = platforms.linux;
                };
              };
            in pkgs.callPackage p { };
        };

        defaultPackage = packages.arweave-bin;

        nixosModule = {
          options = {
            services.arweave = {
              enable = pkgs.lib.mkOption {
                type = pkgs.lib.types.bool;
                default = false;
                description = ''
                  Whether to run Arweave Server.
                '';
              };
            };
          };

          config = pkgs.lib.mkIf pkgs.lib.config.services.arweave.enable {

            environment.systemPackages = [ pkgs.arweave-bin ];

            systemd.services.arweave = {
              description = "Arweave Server";
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                User = "arweave";
                Group = "arweave";
                ExecStart = "${pkgs.arweave-bin}/arweave/bin/start";
                ExecStop = "${pkgs.arweave-bin}/arweave/bin/stop";
              };
            };

            users.users.arweave = {
              description = "Arweave Server user";
              group = "arweave";
            };
          };
        };
      }
    );
}
