{ lib, pkgs, ... }:
let
  db-atelier = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "db-atelier";
    version = "0.9.3";

    src = pkgs.fetchurl {
      url = "https://cdn.dbatelier.app/releases/DB%20Atelier_${version}_aarch64.dmg";
      hash = "sha256-Q+4DRaapir2NKvquaZs4l6EvDU+8WL2nP0ZzEgKFJ8I=";
      name = "db-atelier-${version}.dmg";
    };

    nativeBuildInputs = [ pkgs.undmg ];

    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -a "DB Atelier.app" $out/Applications/

      mkdir -p $out/bin
      cat > $out/bin/db-atelier <<EOF
#!${pkgs.stdenvNoCC.shell}
open -na "$out/Applications/DB Atelier.app" --args "\$@"
EOF
      chmod +x $out/bin/db-atelier

      runHook postInstall
    '';

    meta = {
      description = "DB Atelier - Database client";
      platforms = [ "aarch64-darwin" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };
in
{
  home.packages = lib.mkAfter [ db-atelier ];
}
