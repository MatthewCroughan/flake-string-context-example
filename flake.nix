{
  description = "Example of string contexts to use stuff that you didn't even make a derivation for";

  inputs =
  {
    dnas = {
      url = "gitlab:gh0stl1ne/DNASrep/00c6eed3";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, dnas }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in {
      overlay = final: prev: {
        foo = final.stdenv.mkDerivation rec {
          name = "foo";
          src = self;
          nativeBuildInputs = with final; [ hello ];
          buildPhase = ''
            echo ${dnas}/LICENSE
          '';
          installPhase = ''
            cp ${dnas}/LICENSE $out
          '';
        };
      };
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) foo;
        });
    };
}
