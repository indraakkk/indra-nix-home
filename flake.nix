{
  description = "Indra's modular Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
        };

      baseModules = [
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
    };
}
