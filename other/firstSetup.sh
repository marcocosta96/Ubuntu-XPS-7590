#!/usr/bin/env bash

function Ask_yn(){
    printf "$1 [y/n]"
    read respond
    if [ "$respond" = "y" -o "$respond" = "Y" -o "$respond" = "" ]; then
        return 1
    elif [ "$respond" = "n" -o "$respond" = "N" ]; then
        return 0
    else
        echo 'wrong command!!'
        Ask_yn $1
        return $?
    fi
    unset respond
}

# Update the system
sudo apt update && sudo apt dist-upgrade -y && sudo snap refresh

# Install Codec, extra fonts, DVD support and OpenJDK
sudo apt install ubuntu-restricted-extras p7zip unrar wget curl apt-transport-https -y
sudo apt install fonts-crosextra-caladea fonts-crosextra-carlito -y
sudo apt install libdvd-pkg -y
sudo dpkg-reconfigure libdvd-pkg
sudo apt install openjdk-11-jre -y

# Gnome Shell Extensions
sudo apt install gnome-shell-extensions gnome-tweaks gnome-tweak-tool -y

# GIMP
sudo apt install gimp gimp-plugin-registry gmic -y

# VLC
sudo snap install vlc


# Minimize on click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

# Git
sudo add-apt-repository ppa:git-core/ppa
sudo apt install git -y
Ask_yn "Do you want to config git global user information?"; result=$?
if [ $result = 1 ]; then
    printf "Enter your git global user name: "; read usr_name
    printf "Enter your git global user mail: "; read usr_mail
    git config --global user.name "$usr_name"
    git config --global user.email "$usr_mail"
fi

# Chrome
wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i ./google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y
rm ./google-chrome-stable_current_amd64.deb

# Mailspring
wget -c https://updates.getmailspring.com/download?platform=linuxDeb -O mailspring.deb
sudo dpkg -i ./mailspring.deb
sudo apt-get install -f -y
rm ./mailspring.deb

# VS Code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y
rm ./microsoft.gpg

# LaTeX
sudo apt install texlive-full -y
sudo add-apt-repository ppa:sunderme/texstudio
sudo apt install texstudio -y