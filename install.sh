#!/bin/sh
set -ex

# Make sure that a user flag is set
export USER=vscode

echo "[INSTALL] Nix (single-user)"
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Make Nix and packages installed into the user profile available in this shell.
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

echo "[CONFIGURE] Enable nix-command and flakes"
NIX_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nix"
mkdir -p "$NIX_CONFIG_DIR"
if ! grep -qxF 'extra-experimental-features = nix-command flakes' "$NIX_CONFIG_DIR/nix.conf" 2>/dev/null; then
  printf '%s\n' 'extra-experimental-features = nix-command flakes' >> "$NIX_CONFIG_DIR/nix.conf"
fi

echo "[SETUP] Nix channels"
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

echo "[INSTALL] GitHub CLI"
nix-env -iA nixpkgs.gh

echo "[SETUP] Nix dotfiles"
gh repo clone Carlton-Perkins/nix-dotfiles "$HOME/nix-dotfiles"
cd "$HOME/nix-dotfiles"

nix-shell '<home-manager>' -A install
home-manager switch --flake ./ -b backup

echo "[INSTALL] Nix dotfiles complete"
