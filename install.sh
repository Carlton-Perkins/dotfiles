#!/bin/sh
set -ex

echo "[INSTALL] Nix (single-user)"
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Make Nix and packages installed into the user profile available in this shell.
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

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
