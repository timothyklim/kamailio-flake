{
  description = "kamailio flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";

    src = {
      url = "github:kamailio/kamailio/5.7.0";
      flake = false;
    };
    kamcli-src = {
      url = "github:kamailio/kamcli";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, src, kamcli-src }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      kamailio = import ./build.nix { inherit pkgs src; };
      kamailio-app = flake-utils.lib.mkApp { drv = kamailio; };
      kamcli = import ./kamcli/build.nix {
        inherit pkgs;
        src = kamcli-src;
      };
      derivation = { inherit kamailio kamcli; };
    in
    rec {
      packages.${system} = derivation // { default = kamailio; };
      legacyPackages.${system} = pkgs.extend overlays.default;
      apps.${system} = {
        default = kamailio-app;
        kamailio = kamailio-app;
      };
      nixosModules.default = {
        imports = [
          ./configuration.nix
        ];
        nixpkgs.overlays = [
          overlays.default
        ];
        services.kamailio = {
          package = pkgs.lib.mkDefault kamailio;
        };
        environment.systemPackages = [ kamcli ];
      };
      overlays.default = final: prev: derivation;
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
