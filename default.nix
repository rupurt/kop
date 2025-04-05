{
  config,
  lib,
  dream2nix,
  ...
}: {
  imports = [
    dream2nix.modules.dream2nix.WIP-python-pdm
  ];

  pdm = {
    pyproject = ./pyproject.toml;
  };

  deps = {
    nixpkgs,
    self,
    ...
  }: {
    inherit
      (nixpkgs)
      zlib
      ;
    python = nixpkgs.python312;
    pythonPackages = nixpkgs.python312Packages;
  };

  mkDerivation = {
    src = lib.cleanSourceWith {
      src = lib.cleanSource ./.;
      filter = name: type:
        !(builtins.any (x: x) [
          (lib.hasSuffix ".nix" name)
          (lib.hasPrefix "." (builtins.baseNameOf name))
          (lib.hasSuffix "flake.lock" name)
        ]);
    };
    buildInputs = [
      config.deps.python
    ];
  };

  overrides = {
  };
}
