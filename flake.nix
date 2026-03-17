{
  description = "Indra's modular Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs systems;

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ inputs.nix-openclaw.overlays.default ];
        };

      baseModules = [
        inputs.agenix.homeManagerModules.age
        ./home/profiles/minimal.nix
      ];

      mkHome =
        {
          system,
          modules ? [ ],
          username,
          homeDirectory,
        }:
        let
          pkgs = mkPkgs system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules =
            baseModules
            ++ modules
            ++ [
              {
                home.username = username;
                home.homeDirectory = homeDirectory;
              }
            ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
    in
    {
      formatter = forAllSystems (system: (mkPkgs system).alejandra);

      lib.mkHome = mkHome;

      homeConfigurations = {
        "indra@macos" = mkHome {
          system = "aarch64-darwin";
          username = "indra";
          homeDirectory = "/Users/indra";
          modules = [ ./home/configurations/macos.nix ];
        };

        "indra@linux" = mkHome {
          system = "x86_64-linux";
          username = "indra";
          homeDirectory = "/home/indra";
          modules = [ ./home/configurations/linux.nix ];
        };
      };

      templates = {
        devenv = {
          path = ./templates/devenv;
          description = "Flake + devenv with interactive database and runtime selection";
        };
        default = self.templates.devenv;
      };

      apps = forAllSystems (system:
        let
          pkgs = mkPkgs system;
        in {
          new-flake = {
            type = "app";
            program = toString (pkgs.writeShellScriptBin "new-flake" ''
              export PATH="${pkgs.lib.makeBinPath [pkgs.gum pkgs.git pkgs.gnused pkgs.coreutils]}:$PATH"
              export TEMPLATE_DIR="${./templates/devenv}"
              ${builtins.readFile ./bin/new-flake.sh}
            '' + "/bin/new-flake");
          };
          default = self.apps.${system}.new-flake;
        }
      );
    };
}
