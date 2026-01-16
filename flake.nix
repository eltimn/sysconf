{
  # https://nixos.wiki/wiki/Flakes
  # Inspiration: https://github.com/the-nix-way/nome";
  description = "NixOS and Home Manager configurations for all machines";

  inputs = {
    # Specify the source of Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake modules
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena/stable";
    };

    zen-browser-flake = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    isd-flake.url = "github:isd-project/isd"; # systemd tui
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    sysconf-secrets = {
      # SSH URL of the private repo, shallow clone, tracking the main branch
      url = "git+ssh://forgejo@git.home.eltimn.com/eltimn/sysconf-secrets.git?ref=main&shallow=1";
      flake = false; # we only need the files, not a Nix output
    };

    eltimn-ai-tools = {
      url = "git+ssh://forgejo@git.home.eltimn.com/eltimn/eltimn-ai-tools.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-generators,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          inputs.nix-vscode-extensions.overlays.default
          self.overlays.default
        ];
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };

      # a function to create a home manager configuration
      # hmConfig =
      #   host:
      #   inputs.home-manager.lib.homeManagerConfiguration {
      #     inherit pkgs;

      #     # Specify your home configuration modules here
      #     modules = [
      #       ./nix/machines/${host}/home-nelly.nix
      #       ./nix/modules/home # home manager modules
      #     ];

      #     # Optionally use extraSpecialArgs
      #     # to pass through arguments to home.nix
      #     extraSpecialArgs = {
      #     };
      #   };

      # a function to create a nixos configuration
      nixosConfig =
        hostName:
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = {
            inherit
              inputs
              pkgs-unstable
              ;
          };
          modules = [
            inputs.disko.nixosModules.disko
            ./nix/machines/${hostName}/configuration.nix
            ./nix/modules/system # system modules
            inputs.home-manager.nixosModules.home-manager
            {
              # https://nix-community.github.io/home-manager/nixos-options.xhtml
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.nelly = {
                  imports = [
                    ./nix/machines/${hostName}/home-nelly.nix
                    ./nix/modules/home # home manager modules
                  ];
                };

                # passes arguments to all modules in home.nix
                extraSpecialArgs = {
                  inherit inputs pkgs-unstable;
                };

                sharedModules = [
                  inputs.cosmic-manager.homeManagerModules.cosmic-manager
                  inputs.sops-nix.homeManagerModules.sops
                ];
              };
            }
          ];
        };

      isoConfig =
        installerName:
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./nix/modules/system # sysconf settings
            "${nixpkgs}/nixos/modules/installer/cd-dvd/${installerName}.nix"
            "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
            ./nix/machines/iso/configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };
    in
    {
      # Overlays to use a specific version as the main package. e.g use `pkgs.go` to refer to `pkgs.go_1_23`.
      # Also some flakes and other misc things that are referred to differently than regular packages.
      overlays.default = final: prev: {
        zen-browser = inputs.zen-browser-flake.packages.${prev.stdenv.hostPlatform.system}.default;
        isd = inputs.isd-flake.packages.${prev.stdenv.hostPlatform.system}.default;
        firefox-addons = inputs.firefox-addons.packages.${prev.stdenv.hostPlatform.system};
        git-worktree-runner = prev.callPackage ./nix/pkgs/git-worktree-runner.nix { };
        nix-2-33 = prev.nix.overrideAttrs (oldAttrs: {
          version = "2.33.0";
          src = prev.fetchFromGitHub {
            owner = "NixOS";
            repo = "nix";
            rev = "231d5b41ed1b4b65f4cb875994691a4e40b150d9"; # or specific commit
            hash = "sha256-aVwmNDnTOYZZQbTy++rYS0NOGEu9Zwljg3+TXJmw4TE=";
          };
        });
        # crush = prev.callPackage ./nix/pkgs/crush.nix { };
        unifi-api = inputs.eltimn-ai-tools.packages.${prev.system}.unifi-api;
        # Or for multiple tools:
        # inherit (inputs.eltimn-ai-tools.packages.${prev.system})
        #   unifi-api
        #   another-tool
        #   yet-another
        #   ;
      };

      # Packages
      packages.${pkgs.stdenv.hostPlatform.system} = {
        git-worktree-runner = pkgs.git-worktree-runner;
        do-image = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [ ./nix/machines/do-image/configuration.nix ];
          format = "do";
        };
        colmena = inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena;
        # crush = pkgs.crush;
      };

      # Home Manager configurations. Non-nixos hosts.
      homeConfigurations = {
        # "nelly@illmatic" = hmConfig "illmatic";
      };

      # NixOS hosts
      nixosConfigurations = {
        # cbox = nixosConfig "cbox";
        # illmatic = nixosConfig "illmatic";
        lappy = nixosConfig "lappy";
        ruca = nixosConfig "ruca";

        iso-gnome = isoConfig "installation-cd-graphical-gnome";
        iso-min = isoConfig "installation-cd-minimal";
      };

      # Colmena configuration - combined hive with tags
      colmenaHive = inputs.colmena.lib.makeHive (
        (import ./hive.nix {
          inherit inputs pkgs-unstable;
          lib = nixpkgs.lib;
        })
        // {
          meta = {
            nixpkgs = pkgs;
            specialArgs = {
              inherit inputs pkgs-unstable;
            };
          };
        }
      );

      # tools for managing this repository and the host machines
      devShells.${pkgs.stdenv.hostPlatform.system}.default = pkgs.mkShell {
        packages = with pkgs; [
          age
          borgbackup
          caddy
          doctl
          go-task
          opentofu
          pipx
          sops
          ssh-to-age
        ];

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
