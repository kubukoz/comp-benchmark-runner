{
  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs";
      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      localSystemForScalaCli =
        if system == "aarch64-darwin" then "x86_64-darwin" else system;

      pkgs_extra =
        import nixpkgs { localSystem = localSystemForScalaCli; };

      arm-overrides = final: prev: {
        scala-cli = pkgs_extra.scala-cli;
      };

      pkgs =
        import nixpkgs {
          inherit system;
          overlays = [ arm-overrides ];
        };

      mkJavaShell = jre: pkgs.mkShell {
        packages = [
          (pkgs.sbt.override { inherit jre; })
        ];
      };

    in
    {
      devShell = pkgs.mkShell {
        packages = [
          # for clone
          pkgs.git
          pkgs.gh
          pkgs.scala-cli
          pkgs.nodejs-14_x
          pkgs.yarn
          pkgs.sbt
          pkgs.openjdk17
        ];

        JAVA_HOME = pkgs.openjdk17;
      };
      devShells.jdk11 = mkJavaShell pkgs.openjdk11;
      devShells.jdk8 = mkJavaShell pkgs.openjdk8;
    }
  );
}
