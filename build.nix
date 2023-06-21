{ pkgs, src }:

with pkgs;

stdenv.mkDerivation {
  inherit src;

  name = "kamailio";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    which
    flex
    bison
    openssl
    curl
    pcre
    libxml2
    libmysqlclient
  ];

  phases = ["unpackPhase" "patchPhase" "buildPhase" "installPhase"];

  patchPhase = ''
    sed -i \
      -e 's;-L\$(LOCALBASE);-L${libmysqlclient};g' \
      -e 's;-I\$(LOCALBASE);-I${libmysqlclient.dev};g' \
      src/modules/db_mysql/Makefile
  '';

  buildPhase = ''
    make include_modules="db_mysql" cfg
  '';

  installPhase = ''
    mkdir -p $out
    make prefix=$out install
  '';
}
