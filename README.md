# Parrot-dev-setup.sh
Parrot Os developer script for Termux
# Parrot Dev Setup

**Author:** Chris Nii Emperor

### Features
- Parrot OS (inside Termux) + XFCE desktop (manual VNC start)
- VS Code (official Microsoft build)
- Node.js + npm, Python3, PostgreSQL, Git, curl, build-essential
- Zsh + Oh My Zsh
- Handy shortcuts: `startvnc` / `stopvnc`
- Cleanup script to remove Parrot OS

### Installation
```bash
curl -L -o parrot-dev-setup.sh https://github.com/chrisniiemperor/parrot-dev-setup/raw/main/parrot-dev-setup.sh
chmod +x parrot-dev-setup.sh
./parrot-dev-setup.sh
