{
  description = "Kop. Modern python kubernetes operators";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlay
          (final: prev: {
            kubernetes-helm-wrapped = prev.wrapHelm prev.kubernetes-helm {
              plugins = with prev.kubernetes-helmPlugins; [
                helm-diff
                helm-git
                helm-s3
                helm-secrets
              ];
            };
          })
        ];
      };
    in {
      # packages exported by the flake
      packages = {};

      # nix fmt
      formatter = pkgs.alejandra;

      # nix develop -c $SHELL
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          argc
          k3d
          k9s
          kafkactl
          kcat
          kubectl
          kubernetes-helm-wrapped
          skaffold
          uv
        ];

        shellHook = ''
          export IN_NIX_DEVSHELL=1;
          export KUBECONFIG="$(realpath .)/.local/kubeconfig";
        '';
      };
    });
  in
    outputs
    // {
      # Overlay that can be imported so you can access the packages
      # using kop.overlay
      overlay = final: prev: {
        kop = outputs.packages.${prev.system};
      };
    };
}
