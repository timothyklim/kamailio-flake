{ pkgs, src }:

with pkgs; with python310Packages; buildPythonApplication rec {
  inherit src;

  name = "kamcli";

  buildInputs = [
    click
    prompt-toolkit
    pyaml
    pyyaml
    pygments
    sqlalchemy
    tabulate
    wheel
    mysqlclient
  ];
  propagatedBuildInputs = buildInputs;

  doCheck = false;
}
