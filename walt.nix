{ config, lib, pkgs, ... }:

#let vim-custom = (import ./vim-custom/default.nix {}); in
let docker-ide = (import ./docker-ide.nix {}); in
{
  imports = [ 
  ];

  home-manager.users.walt = {
    # This is for a virtual machine
    #services.screen-locker.enable = false;

    programs.firefox = {
      enable = true;

      profiles = {
        walt = {
          settings = {
            "browser.ctrlTab.recentlyUsedOrder" = false;
          };
        };
      };
    };
    programs.git = {
      enable = true;
      userName = "wwoods";
      userEmail = "waltw@galois.com";
    };

    gtk.enable = true;
    gtk.theme.name = "Breeze-Noir-Dark";

    programs.gnome-terminal.profile.Unnamed = {
      colors = "Tango Dark";
      palette = "Solarized";
    };

    # https://nixos.wiki/wiki/Vscode#Managing_extensions
    home.packages =
      let vscode-personal-extensions = (with pkgs.vscode-extensions; [
        ms-vscode.cpptools
        ]); in
      let vscode-personal = pkgs.vscode-with-extensions.override {
          vscodeExtensions = vscode-personal-extensions;
        }; in
      with pkgs; [ breeze-gtk conda docker-ide inkscape libreoffice obs-studio vscode-personal ];
    ##xdg.configFile.".vimrc".source = ./docker-ide/ide-base/dot-files/.vimrc;
    #home.file.".vimrc".source = ./docker-ide/ide-base/dot-files/.vimrc;
    #home.file.".ctags.vimrc".source = ./docker-ide/ide-base/dot-files/.ctags.vimrc;
    #home.file.".vim/bundle/Vundle.vim".source = (builtins.fetchTarball https://github.com/VundleVim/Vundle.vim/archive/master.tar.gz);
    #home.file."docker-ide".source = ./docker-ide;
    # Still need to manually execute "docker-ide-setup" on first run
    home.sessionVariables.EDITOR = "vim";

    home.file.".config/Code/User/settings.json".source = ./config-vscode.json;
  };
}

