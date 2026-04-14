# Kali Linux Essentials Configuration

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kali Linux](https://img.shields.io/badge/Kali-Linux-blue.svg)](https://www.kali.org/)
[![ZSH](https://img.shields.io/badge/Shell-ZSH-green.svg)](https://www.zsh.org/)
[![Tmux](https://img.shields.io/badge/Tmux-Plugin%20Ready-red.svg)](https://github.com/tmux-plugins/tpm)

A complete, battle-tested configuration for Kali Linux with an enhanced ZSH prompt and powerful tmux setup. Perfect for penetration testing, CTF competitions, and daily driving.

## 📸 Features

### ZSH Configuration
- **Custom 2-line prompt** with IP addresses (Ethernet, VPN, WiFi)
- **Nerd Font glyphs** for beautiful icons (requires Nerd Font)
- **Syntax highlighting** for commands, paths, and options
- **Auto-suggestions** based on command history
- **Case-insensitive tab completion**
- **Ctrl+P** to toggle between 2-line and 1-line prompt
- **Exit code and background job indicators** in prompt

### Tmux Configuration
- **Ctrl+A** prefix (instead of default Ctrl+B)
- **Mouse support** with intelligent scrolling
- **Vi-style copy mode** with automatic clipboard integration
- **Alt+Arrow** to switch panes without prefix
- **Shift+Left/Right** to switch windows
- **Ctrl+Space** to zoom pane
- **Automatic window renaming** based on active process
- **Logging support** via tmux-logging plugin

## 🚀 Quick Installation

### One-Command Install
```bash
git clone https://github.com/akuma-log/MyKaliTerminal.git ~/Kali-Config
cd ~/Kali-Config
chmod +x install.sh
./install.sh
