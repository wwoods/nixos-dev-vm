{ pkgs ? import <nixpkgs> {} }:

# Special package for vim + tmux; requires running "docker-ide-setup" on first
# run.

let docker-ide-ctags = pkgs.stdenv.mkDerivation {
  name = "docker-ide-ctags";
  src = (builtins.fetchGit { url = "https://github.com/masatake/ctags.git"; });
  buildInputs = with pkgs; [ autoconf automake gnumake perl pkg-config ];
  buildPhase = ''
    patchShebangs ./misc
    ./autogen.sh && ./configure && make
    '';
  installPhase = ''
    make install prefix="$out"
    '';
}; in
let docker-ide-setup = pkgs.writeShellScriptBin "docker-ide-setup" ''
SOURCE="''${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

  # Use built version of ctags via nix... getting build working in script was
  # awful.
  rm -rf $HOME/.ctags.inst
  cp -a ${docker-ide-ctags} ~/.ctags.inst

  # Now run setup-symlinks.
  bash -c "cd $DIR/../docker-ide/ && ./setup-symlinks.sh"
''; in
let docker-ide-meta = pkgs.stdenv.mkDerivation {
  name = "docker-ide";
  src = (fetchGit { url="https://github.com/wwoods/docker-ide"; });

  unpackPhase = ''
    cp -a $src ./docker-ide
  '';

  buildInputs = with pkgs; [ docker-ide-setup ];
  buildPhase = ''
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -a docker-ide $out
    cp -a ${docker-ide-setup}/bin/docker-ide-setup $out/bin/
  '';
}; in
pkgs.symlinkJoin {
  name = "docker-ide";
  paths = [ docker-ide-meta pkgs.git pkgs.tmux pkgs.vimHugeX ];
}

