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
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
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

      # Overlay: copy openclaw.plugin.json manifests from extensions/ (source)
      # into dist/extensions/ (built).  The upstream nix build compiles TS→JS
      # into dist/extensions/ but doesn't carry the JSON manifests.  Without
      # them the plugin-based architecture silently skips all channels.
      openclawManifestFixOverlay = final: prev:
        let
          patchedGateway = prev.openclaw-gateway.overrideAttrs (old: {
            dontFixup = false;
            postFixup = ''
              src_ext="$out/lib/openclaw/extensions"
              dst_ext="$out/lib/openclaw/dist/extensions"
              if [ -d "$src_ext" ] && [ -d "$dst_ext" ]; then
                for src_dir in "$src_ext"/*/; do
                  name="$(basename "$src_dir")"
                  manifest="$src_dir/openclaw.plugin.json"
                  if [ -f "$manifest" ] && [ -d "$dst_ext/$name" ]; then
                    cp "$manifest" "$dst_ext/$name/openclaw.plugin.json"
                  fi
                done
              fi
            '';
          });
        in {
          openclaw-gateway = patchedGateway;
          openclaw = prev.openclaw.override { openclaw-gateway = patchedGateway; };
        };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            inputs.nix-openclaw.overlays.default
            openclawManifestFixOverlay
          ];
        };

      baseModules = [
        inputs.agenix.homeManagerModules.age
        inputs.nixvim.homeModules.nixvim
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
