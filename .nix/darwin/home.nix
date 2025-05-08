{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  programs.home-manager.enable = true;

  home.username = "foaxylabs";
  home.homeDirectory = "/Users/foaxylabs";
  xdg.enable = true;

  xdg.configFile.nvim.source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.config/nvim";

  home.stateVersion = "24.11";

  programs = {
    tmux = import ../home/tmux.nix {inherit pkgs;};
    zsh = import ../home/zsh.nix {inherit config pkgs lib; };
    zoxide = (import ../home/zoxide.nix { inherit config pkgs; });
    fzf = import ../home/fzf.nix {inherit pkgs;};
    oh-my-posh = import ../home/oh-my-posh.nix {inherit pkgs;};
  };
}
