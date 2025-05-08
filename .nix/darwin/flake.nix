{
  description = "Foaxy Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    #Templ
    templ.url = "github:a-h/templ";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    nixpkgs-unstable,
    templ,
    home-manager,
    ...
  } @ inputs: let

    username = "foaxylabs";

    add-unstable-packages = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
      };
    };
    
    configuration = {
      pkgs,
      lib,
      config,
      ...
    }: {
      nixpkgs.config.allowUnfree = true;

      nixpkgs.overlays = [
        inputs.templ.overlays.default
        add-unstable-packages
      ];

      environment.systemPackages =
        [
          pkgs.alacritty
          # pkgs.air
          # pkgs.act
          # pkgs.awscli
          # pkgs.bun
          # pkgs.ffmpeg
          # pkgs.jujutsu
          # pkgs.git
          # pkgs.gh
          # pkgs.gnupg
          # pkgs.unstable.go_1_23
          # pkgs.python313
          # pkgs.iperf
          # pkgs.lua-language-server
          # pkgs.mkalias
          # pkgs.neovim
          # pkgs.nil
          # pkgs.obsidian
          # pkgs.opentofu
          # pkgs.pass
          # pkgs.postgresql_16
          # pkgs.rclone
          # pkgs.ripgrep
          # pkgs.rustup
          # pkgs.sqlc
          # pkgs.stylua
          # pkgs.unstable.stripe-cli
          # pkgs.tailwindcss
          # pkgs.tailwindcss-language-server
          # pkgs.qmk
          # pkgs.templ
          # pkgs.tmux
          # pkgs.unstable.amber-lang
          # pkgs.zoxide
        ];

      users.users.${username}  = {
        home = "/Users/${username}";
      };

      homebrew = {
        enable = true;
        brews = [
          "mas"
        ];
        casks = [
          # "hammerspoon"
          # "amethyst"
          # "alfred"
          # "logseq"
          # "notion"
          # "firefox"
          # "discord"
          # "iina"
          # "the-unarchiver"
          "visual-studio-code"
        ];
        taps = [
        ];
        masApps = {
          Yoink = 457622435;
        };
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # services.postgresql = {
      #   enable = true;
      #   package = pkgs.postgresql_16;
      # };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      system.defaults = {
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleShowAllExtensions = true;
        loginwindow.GuestEnabled = false;
        finder.FXPreferredViewStyle = "clmv";
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."foaxy" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          # `home-manager` config
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home.nix;
        }
      ];
    };

    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      modules = [ ./home.nix ];
      username = username;
      homeDirectory = "/Users/${username}";
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."foaxy".pkgs;
  };
}
