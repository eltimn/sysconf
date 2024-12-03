#!/bin/bash

set -e

COMPUTER_TYPE="${1:-workstation}"

#SECRET_BACKUP_DIR=/media/nelly/A70F-39C0/backup/nelly/`hostname`

# add sublme text gpg key and repo
# wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
# echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y autoremove
sudo apt-get -y autoclean

# sudo fwupdmgr -y get-devices
# sudo fwupdmgr -y get-updates
# sudo fwupdmgr -y update

# install some required tools
sudo apt-get install -y curl git jq stow wget apt-transport-https tree gparted zsh neovim

# install ansible and related tools
# sudo apt-get install -y ansible python3-apt python3-yaml python3-pip python3-gpg

# install sublime text
# sudo apt-get install -y sublime-text

# install some flatpaks
flatpak install flathub com.logseq.Logseq
# flatpak install flathub org.telegram.desktop

# install nix
# curl -L https://nixos.org/nix/install | sh
# https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# install rustup
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# prepare dirs
# if [[ -d "$HOME/Documents" && ! -L "$HOME/Documents" ]]; then
#   rmdir $HOME/Documents
#   ln -s $HOME/Dropbox/Documents $HOME/Documents
# fi
# if [[ -d "$HOME/Pictures" && ! -L "$HOME/Pictures" ]]; then
#   rmdir $HOME/Pictures
# fi

# # links
# cd $HOME
# ln -s $HOME/Dropbox/Camera $HOME/Camera
# ln -s $HOME/Dropbox/Images $HOME/Images
# ln -s $HOME/Dropbox/Pictures $HOME/Pictures

# restore dirs from backup
#rsync -avz --progress /mnt/backup/nelly/ $HOME

# extract backed up secret dir
# if [ -d "$SECRET_BACKUP_DIR" ]; then
#   echo "Extracting backed up secret dir"
#   tar xvf $SECRET_BACKUP_DIR/secret.tgz -C $HOME
#   tar xvf $SECRET_BACKUP_DIR/ssh.tgz -C $HOME
#   mkdir $HOME/.sbt
#   tar xvf $SECRET_BACKUP_DIR/gpg.tgz -C $HOME/.sbt
# else
#   echo "Backed up secret dir not found. Creating empty directory."
#   mkdir $HOME/secret
# fi

# # kitty
# curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
# # Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
# # your system-wide PATH)
# cd $HOME/.local/kitty.app
# stow --verbose --stow --target=$HOME/.local/bin bin
# # ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
# # Place the kitty.desktop file somewhere it can be found by the OS
# cp $HOME/.local/kitty.app/share/applications/kitty.desktop $HOME/.local/share/applications/
# # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
# cp $HOME/.local/kitty.app/share/applications/kitty-open.desktop $HOME/.local/share/applications/
# # Update the paths to the kitty and its icon in the kitty.desktop file(s)
# sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" $HOME/.local/share/applications/kitty*.desktop
# sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" $HOME/.local/share/applications/kitty*.desktop


# nix home-manager handles oh-my-zsh
# oh-my-zsh
# if [ ! -e "$HOME/.oh-my-zsh" ]; then
#   git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
# fi

# Create a user and group for Ollama
sudo useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama
sudo usermod -a -G ollama $(whoami)

# change default shell to zsh (requires restart)
chsh -s $(which zsh)

# env zsh
# . ~/.zshrc

exit 0
