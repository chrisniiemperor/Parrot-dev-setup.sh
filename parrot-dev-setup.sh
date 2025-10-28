# Parrot OS Developer Setup Script for Termux
# Author: Chris Nii Emperor
# Interactive installer with cleanup option

set -e
# ASCII Banner
echo "=========================================="
echo "🦜  Parrot Dev Setup by Chris-Tech"
echo "------------------------------------------"
echo "Install Parrot OS + XFCE + VS Code + Dev Tools"
echo "=========================================="
echo

# Automatic Termux update
echo "🔹 Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Prompt helper
ask_install() {
    while true; do
        read -rp "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Install Parrot OS via proot-distro
if ask_install "Install Parrot OS via proot-distro?"; then
    pkg install -y proot-distro wget
    proot-distro install parrot
fi

echo "🔹 Logging into Parrot OS..."
proot-distro login parrot -- bash <<'EOF'
set -e

# Function to install packages interactively
install_pkg() {
    pkg_name="$1"
    display_name="$2"
    read -rp "Install $display_name? [y/n]: " answer
    if [[ $answer =~ ^[Yy] ]]; then
        apt update && apt install -y "$pkg_name"
    else
        echo "Skipping $display_name..."
    fi
}

# Update & upgrade inside Parrot
echo "🔹 Updating Parrot OS..."
apt update && apt upgrade -y

# Install XFCE desktop & VNC
install_pkg "xfce4 xfce4-goodies tightvncserver dbus-x11" "XFCE Desktop + VNC"

# Configure VNC
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup <<'XSTARTUP'
#!/bin/bash
xrdb $HOME/.Xresources
dbus-launch startxfce4 &
XSTARTUP
chmod +x ~/.vnc/xstartup

# Install Zsh & Oh My Zsh
install_pkg "zsh" "Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh already installed"
else
    export RUNZSH=no
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" || true
fi

# Install Node.js + npm
install_pkg "nodejs npm" "Node.js + npm"
npm install -g npm@latest

# Install Python3 & Git
install_pkg "python3 python3-pip git curl build-essential" "Python3 + Git + curl + build tools"

# Install PostgreSQL
install_pkg "postgresql postgresql-contrib" "PostgreSQL"

# Install VS Code (official)
install_pkg "wget gnupg software-properties-common apt-transport-https" "VS Code dependencies"
if [[ ! -f "/usr/share/keyrings/packages.microsoft.gpg" ]]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
    sh -c 'echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    apt update
    apt install -y code
    rm -f packages.microsoft.gpg
fi

# Create start/stop VNC shortcuts
echo "alias startvnc='vncserver :1 -geometry 1280x720 -depth 24'" >> ~/.bashrc
echo "alias stopvnc='vncserver -kill :1'" >> ~/.bashrc
source ~/.bashrc

# Cleanup option
if read -rp "Do you want to create cleanup script? [y/n]: " cleanup; [[ $cleanup =~ ^[Yy] ]]; then
    cat > ~/remove-parrot.sh <<'CLEANUP'
#!/usr/bin/env bash
echo "Removing Parrot OS and all files..."
rm -rf $HOME/.proot-distro
echo "Cleanup complete!"
CLEANUP
    chmod +x ~/remove-parrot.sh
    echo "You can run ~/remove-parrot.sh to remove Parrot OS anytime."
fi

echo
echo "✅ Parrot Dev Setup Complete!"
echo "Use 'startvnc' to launch desktop and 'stopvnc' to stop."
EOF
