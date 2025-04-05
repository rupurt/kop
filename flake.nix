{
  description = "Kop. Modern python kubernetes operators";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix?rev=1a5e625de7715a542bc4a15ec30fc05a48924c0d";
    nixpkgs.follows = "dream2nix/nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    dream2nix,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          self.overlay
        ];
      };
      get_dev_packages = groups:
        with groups;
          lint.packages
          // test.packages
          // dist.packages;
    in rec {
      # packages exported by the flake
      packages = rec {
        prod = dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs;
          modules = [
            ./default.nix
            {
              paths.projectRoot = ./.;
              paths.projectRootFile = "flake.nix";
              paths.package = ./.;
              pdm.lockfile = ./pdm.prod.lock;
            }
          ];
        };
        dev = dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs;
          modules = [
            ./default.nix
            {
              paths.projectRoot = ./.;
              paths.projectRootFile = "flake.nix";
              paths.package = ./.;
              pdm.lockfile = ./pdm.dev.lock;
            }
          ];
        };
        default = prod;
      };

      # nix fmt
      formatter = pkgs.alejandra;

      # nix develop -c $SHELL
      devShells.default = pkgs.mkShell {
        inputsFrom = [
          self.packages.${system}.dev.devShell
        ];

        # dream2nix doesn't currently support automatically loading groups or PEP 735 yet
        # - https://github.com/nix-community/dream2nix/issues/1000
        # - https://peps.python.org/pep-0735/
        buildInputs =
          []
          ++ map (x: (pkgs.lib.head (pkgs.lib.attrValues x)).public) (
            pkgs.lib.attrValues (get_dev_packages self.packages."${system}".dev.config.groups)
          );

        packages = with pkgs; [
          packages.dev
          argc
        ];

        shellHook = ''
          export IN_NIX_DEVSHELL=1;
        '';
      };
    });
  in
    outputs
    // {
      # # Overlay that can be imported so you can access the packages
      # # using kop.overlay
      overlay = final: prev: {
        kop = outputs.packages.${prev.system};
      };
    };
}
