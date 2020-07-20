{ pkgs ? import <nixpkgs> {} }:

# Calling it -- on Jul 17th, 2020, this derivation was declared a failure. Basically, Vundle requires
# a writeable directory, which nix will never provide.

let vundle = builtins.fetchTarball https://github.com/VundleVim/Vundle.vim/archive/master.tar.gz; in
pkgs.stdenv.mkDerivation {
  name = "vim-custom";
  srcs = [
    (builtins.path {path=../docker-ide/ide-base/dot-files/.vimrc; name="vimrc";})
    (builtins.path {path=../docker-ide/ide-base/dot-files/.ctags.vimrc; name="ctags.vimrc";})
  ];
  unpackPhase = ''
    for srcFile in $srcs; do
      cp -r --preserve=mode,timestamp $srcFile $(stripHash $srcFile)
    done
  '';
  # `cacert git` required for vundle to fetch packages.
  buildInputs = with pkgs; [ cacert git vimHugeX vundle ];
  buildPhase = ''
    # All attempts to copy vim failed... better to call as dependency in place

    # Copy over custom .vimrc, and install plugins
    export VIMINIT='source vimhome/vimrc'
    export MYVIMRC='vimhome/vimrc'

    mkdir vimhome
    cp -a vimrc vimhome/vimrc
    cp -a ctags.vimrc vimhome/.ctags.vimrc
    mkdir -p vimhome/bundle
    cp -a ${vundle} vimhome/bundle/Vundle.vim
    bash -c 'echo | echo | vim +PluginInstall +qall > /dev/null'
  '';
  installPhase = ''
    mkdir $out
    cp -a vimhome $out/vimhome
    mkdir -p $out/bin
    echo "#! /bin/bash" >> $out/bin/vim
    #echo "export VIM='$out/vimhome'" >> $out/bin/vim
    echo "export VIMINIT='source $out/vimhome/vimrc'" >> $out/bin/vim
    echo "export MYVIMRC='$out/vimhome/vimrc'" >> $out/bin/vim
    echo 'exec -a "$0" '${pkgs.vimHugeX}/bin/vim' "$@"' >> $out/bin/vim
    chmod a+x $out/bin/vim
  '';
}
