{ pkgs, src }:

with pkgs; stdenv.mkDerivation {
  inherit src;

  name = "kamailio";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    gnugrep
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
    patchShebangs utils/kamctl/kamctl

    sed -i \
      -e 's;-L\$(LOCALBASE);-L${libmysqlclient};g' \
      -e 's;-I\$(LOCALBASE);-I${libmysqlclient.dev};g' \
      src/modules/db_mysql/Makefile

    sed -i \
      -e 's;# DBENGINE=MYSQL;DBENGINE=MYSQL;g' \
      -e 's;# AWK;AWK;g' \
      -e 's;# EGREP;EGREP;g' \
      -e 's;# EXPR;EXPR;g' \
      -e 's;# LAST_LINE;LAST_LINE;g' \
      -e 's;# MD5;MD5;g' \
      utils/kamctl/kamctlrc
  '';

  buildPhase = ''
    make include_modules="db_mysql" cfg
  '';

  installPhase = ''
    mkdir -p $out
    make prefix=$out install
  '';
}
