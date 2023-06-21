{
  description = "kamailio flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";

    src = {
      url = "github:kamailio/kamailio/5.7.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, src }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      kamailio = import ./build.nix { inherit pkgs src; };
      kamailio-app = flake-utils.lib.mkApp { drv = kamailio; };
      derivation = { inherit kamailio; };
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
      };
      overlays.default = final: prev: derivation;
    };
}
