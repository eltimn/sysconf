{
  # https://nixos.wiki/wiki/Flakes
  # Inspiration: https://github.com/the-nix-way/nome";
  description = "NixOS and Home Manager configurations for all machines";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser-flake.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      disko,
      zen-browser-flake,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };

      # a function to load host specific settings
      loadVars = host: nixpkgs.lib.importTOML ./nix/machines/${host}/settings.toml;

      # a function to create a home manager configuration
      hmConfig =
        host:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [ ./nix/machines/${host}/home.nix ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = {
            # load the settings
            vars = loadVars host;
          };
        };

      # a function to create a nixos configuration
      nixosConfig =
        host:
        let
          vars = loadVars host;
        in
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          # these get inherited by the modules??
          specialArgs = {
            inherit inputs vars;
          };
          modules = [
            disko.nixosModules.disko
            ./nix/machines/${vars.host}/disks.nix
            ./nix/machines/${vars.host}/hardware-configuration.nix
            ./nix/machines/${vars.host}/system.nix
            home-manager.nixosModules.home-manager
            {
              # https://nix-community.github.io/home-manager/nixos-options.xhtml
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${vars.user} = import ./nix/machines/${vars.host}/home.nix;

                # passes arguments to all modules in home.nix
                extraSpecialArgs = {
                  inherit vars pkgs-unstable;
                };
              };
            }
          ];
        };

      # nixIsNixOS = builtins.pathExists /etc/NIXOS;
      # nixSwitchCmd = if nixIsNixOS then "sudo nixos-rebuild" else "home-manager";

      # `builtins.readFile` doesn't work with files that are not part of the git repo.
      # path to the secrets directory
      # homeDir = builtins.getEnv "HOME";
      # secretsPath = builtins.toPath "${homeDir}/secret/nix";

      # a function to read a secret file
      # readSecretFile = p: builtins.readFile (secretsPath + p);

      # sshKeys = {
      #   lappy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKlXvCa8D1VqasrHkgsnajPhaUA5N2pJ0b9OASPqYij tim@lappy";
      #   ruca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXS57Mn5Hsbkyv/byapcmgEVkRKqEnudWaCSDmpkRdb nelly@ruca";
      # };

      # public ssh keys
      sshKeys = nixpkgs.lib.importTOML ./ssh_keys.toml;
    in
    {
      # Overlays to use a specific version as the main package. e.g use `pkgs.go` to refer to `pkgs.go_1_23`.
      # Also some flakes and other misc things that are referred to differently than regular packages.
      overlays.default = final: prev: {
        zen-browser = zen-browser-flake.packages.${prev.system}.default;
      };

      # Home Manager configurations. Non-nixos hosts.
      homeConfigurations = {
        "nelly@ruca" = hmConfig "ruca";
        "nelly@illmatic" = hmConfig "illmatic";
      };

      # NixOS hosts
      nixosConfigurations = {
        cbox = nixosConfig "cbox";
        lappy = nixosConfig "lappy";
        ruca = nixosConfig "ruca";

        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./nix/machines/iso/configuration.nix
          ];
          specialArgs = { inherit inputs sshKeys; };
        };
      };

      # tools for managing this repository and the host machines
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.go-task
        ];

        # env = {
        #   NIX_CMD = "${nixSwitchCmd}";
        #   IS_NIXOS = "${builtins.toString true}";
        # };

        shellHook = ''
          echo "Welcome to sysconf!"
        '';
      };

      # nix flake templates
      templates = rec {
        default = basic;

        basic = {
          path = ./nix/templates/basic;
          description = "A basic flake";
        };

        go-basic = {
          path = ./nix/templates/go-basic;
          description = "A basic Go flake";
        };

        go-templ = {
          path = ./nix/templates/go-templ;
          description = "A Go/Templ flake";
        };
      };
    };
}
