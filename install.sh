#!/bin/bash

# Kali Linux Configuration Installer
# Installs custom .zshrc and .tmux.conf with all dependencies

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_color() {
    echo -e "${2}${1}${NC}"
}

print_success() {
    print_color "✓ $1" "$GREEN"
}

print_error() {
    print_color "✗ $1" "$RED"
}

print_info() {
    print_color "→ $1" "$BLUE"
}

print_warning() {
    print_color "⚠ $1" "$YELLOW"
}

# Check if running as root (not recommended for dotfiles)
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. This is not recommended for dotfile installation."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_info "Installing Kali Linux configuration from: $SCRIPT_DIR"

# ============================================
# Install dependencies
# ============================================
print_info "Checking/Installing dependencies..."

# UPDATE AND UPGRADE SYSTEM FIRST
print_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System updated and upgraded"

DEPS=(
    "zsh"
    "tmux"
    "xclip"
    "git"
    "curl"
    "wget"
)

MISSING_DEPS=()
for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    print_info "Installing missing dependencies: ${MISSING_DEPS[*]}"
    sudo apt update
    sudo apt install -y "${MISSING_DEPS[@]}"
else
    print_success "All dependencies already installed"
fi

# ============================================
# Install Oh-My-Zsh (optional but recommended)
# ============================================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh-My-Zsh installed"
else
    print_success "Oh-My-Zsh already installed"
fi

# ============================================
# Install ZSH plugins
# ============================================
print_info "Installing ZSH plugins..."

# zsh-syntax-highlighting
if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
else
    print_success "zsh-syntax-highlighting already installed"
fi

# zsh-autosuggestions
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
else
    print_success "zsh-autosuggestions already installed"
fi

# ============================================
# Install .zshrc
# ============================================
print_info "Configuring .zshrc..."

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    BACKUP_FILE="$HOME/.zshrc.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP_FILE"
    print_info "Backed up existing .zshrc to $BACKUP_FILE"
fi

# Copy new .zshrc (using the updated Kali 2026.1 compatible version)
if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    # Update the paths for plugins in the .zshrc
    sed -i "s|/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh|$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh|g" "$SCRIPT_DIR/.zshrc"
    sed -i "s|/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh|$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh|g" "$SCRIPT_DIR/.zshrc"
    
    cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
    print_success ".zshrc installed"
else
    print_error ".zshrc not found in current directory"
    exit 1
fi

# ============================================
# Install .tmux.conf and TPM
# ============================================
print_info "Configuring tmux..."

# Backup existing .tmux.conf
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
    BACKUP_FILE="$HOME/.tmux.conf.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.tmux.conf" "$BACKUP_FILE"
    print_info "Backed up existing .tmux.conf to $BACKUP_FILE"
fi

# Copy new .tmux.conf
if [ -f "$SCRIPT_DIR/tmux.conf" ]; then
    cp "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"
    print_success ".tmux.conf installed"
else
    print_error "tmux.conf not found in current directory"
    exit 1
fi

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    print_info "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    print_success "TPM installed"
else
    print_success "TPM already installed"
fi

# ============================================
# Install Nerd Fonts (optional)
# ============================================
print_info "Checking for Nerd Fonts..."

if [ ! -f "$HOME/.local/share/fonts/CascadiaCodeNF.ttf" ] && [ ! -f "$HOME/.local/share/fonts/MesloLGSNF.ttf" ]; then
    print_warning "Nerd Fonts not found. Your prompt uses Nerd Font glyphs."
    read -p "Install recommended Nerd Fonts? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Downloading Cascadia Code Nerd Font..."
        mkdir -p "$HOME/.local/share/fonts"
        cd /tmp
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip
        unzip -q CascadiaCode.zip -d CascadiaCode
        cp CascadiaCode/*.ttf "$HOME/.local/share/fonts/"
        fc-cache -fv
        cd "$SCRIPT_DIR"
        print_success "Nerd Fonts installed. Please set your terminal font to 'CaskaydiaCove Nerd Font'"
    else
        print_warning "Skipping Nerd Fonts. Your prompt may show missing glyphs."
    fi
else
    print_success "Nerd Fonts already installed"
fi

# ============================================
# Set ZSH as default shell
# ============================================
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Changing default shell to ZSH..."
    if chsh -s "$(which zsh)"; then
        print_success "Default shell changed to ZSH. Please log out and back in."
    else
        print_warning "Could not change shell. You may need to run: chsh -s $(which zsh)"
    fi
else
    print_success "ZSH is already default shell"
fi

# ============================================
# Create local bin directory for custom scripts
# ============================================
mkdir -p "$HOME/.local/bin"

# Create helper script to reload tmux config
cat > "$HOME/.local/bin/tmux-reload" << 'EOF'
#!/bin/bash
tmux source-file ~/.tmux.conf
echo "Tmux config reloaded!"
EOF
chmod +x "$HOME/.local/bin/tmux-reload"

# Create helper script for tmux logging
cat > "$HOME/.local/bin/tmux-log-start" << 'EOF'
#!/bin/bash
echo "Press Prefix + Shift + P to start logging"
echo "Press again to stop logging"
echo "Logs saved in ~/tmux-logging/"
EOF
chmod +x "$HOME/.local/bin/tmux-log-start"

print_success "Helper scripts created in ~/.local/bin"

# ============================================
# Final instructions
# ============================================
echo
print_color "==========================================" "$GREEN"
print_color "Installation Complete!" "$GREEN"
print_color "==========================================" "$GREEN"
echo
print_info "Next steps:"
echo "  1. Start a new tmux session: tmux"
echo "  2. Inside tmux, install plugins: Prefix + Shift + I (Ctrl+A then Shift+I)"
echo "  3. Reload tmux config: tmux source ~/.tmux.conf"
echo "  4. If you changed your shell, log out and back in"
echo "  5. Set your terminal font to a Nerd Font (e.g., 'CaskaydiaCove Nerd Font')"
echo
print_info "Useful commands:"
echo "  - tmux-reload          (reload tmux config)"
echo "  - tmux-log-start       (instructions for tmux logging)"
echo "  - Ctrl+P               (toggle zsh prompt style)"
echo
print_warning "If you see missing glyphs, install a Nerd Font and configure your terminal"
echo
read -p "Press Enter to exit..."
