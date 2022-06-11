{
  inputs = {
    devshell.url = github:numtide/devshell;
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
    flake-utils.url = github:numtide/flake-utils;
    precommix.url = gitlab:moduon%2Fdevsecops/precommix;

    # Optimizations
    devshell.inputs.flake-utils.follows = "flake-utils";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    precommix.inputs.devshell.follows = "devshell";
    precommix.inputs.flake-compat.follows = "flake-compat";
    precommix.inputs.flake-utils.follows = "flake-utils";
    precommix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    devshell,
    flake-utils,
    precommix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlay];
      };
    in {
      devShells.default = pkgs.devshell.mkShell {
        commands = [
          {package = pkgs.pre-commit;}
        ];
        devshell.packages = [
          precommix.packages."${system}".precommix-env
        ];
        devshell.startup.precommix.text = ''
          pre-commit install -t pre-commit -t commit-msg
        '';
      };
    });
}
