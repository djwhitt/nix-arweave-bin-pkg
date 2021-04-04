{
  description = "Arweave server binary package flake";

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in rec {
      packages.x86_64-linux.arweave-bin =
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
              mkdir $out
              mv * $out/
            '';

            meta = with lib; {
              homepage = https://github.com/ArweaveTeam/arweave;
              description = "Arweave Server.";
              platforms = platforms.linux;
            };
          };
        in pkgs.callPackage p { };

      defaultPackage.x86_64-linux = packages.x86_64-linux.arweave-bin;
    };
}
