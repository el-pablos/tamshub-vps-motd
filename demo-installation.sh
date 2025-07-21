#!/bin/bash

# Demo Installation Script for TamsHub VPS MOTD
# This script demonstrates the installation process without actually installing

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to simulate typing effect
type_text() {
    local text="$1"
    local delay="${2:-0.03}"
    
    for ((i=0; i<${#text}; i++)); do
        printf "%c" "${text:$i:1}"
        sleep "$delay"
    done
    printf "\n"
}

# Function to simulate command execution
simulate_command() {
    local command="$1"
    local output="$2"
    
    printf "${CYAN}$ ${WHITE}%s${NC}\n" "$command"
    sleep 1
    if [ -n "$output" ]; then
        printf "%s\n" "$output"
    fi
    sleep 0.5
}

# Main demo function
demo_installation() {
    clear
    
    printf "${CYAN}${WHITE}\n"
    printf "╔══════════════════════════════════════════════════════════════╗\n"
    printf "║                TAMSHUB VPS MOTD INSTALLATION DEMO            ║\n"
    printf "║              Professional System Information Display         ║\n"
    printf "╚══════════════════════════════════════════════════════════════╝\n"
    printf "${NC}\n"
    
    type_text "Welcome to the TamsHub VPS MOTD installation demonstration!" 0.05
    printf "\n"
    type_text "This demo shows you what the installation process looks like." 0.05
    type_text "The actual installation requires root privileges and will modify your system." 0.05
    printf "\n"
    
    read -p "Press Enter to continue with the demo..."
    clear
    
    printf "${BLUE}[DEMO]${NC} Starting installation simulation...\n\n"
    
    # Step 1: Download files
    printf "${GREEN}Step 1: Download Installation Files${NC}\n"
    simulate_command "mkdir -p ~/tamshub-vps-motd && cd ~/tamshub-vps-motd" ""
    simulate_command "wget https://github.com/tamshub/vps-motd/releases/latest/download/vps-sysinfo.sh" "${GREEN}✓${NC} Downloaded vps-sysinfo.sh"
    simulate_command "wget https://github.com/tamshub/vps-motd/releases/latest/download/install-motd.sh" "${GREEN}✓${NC} Downloaded install-motd.sh"
    simulate_command "chmod +x install-motd.sh" ""
    printf "\n"
    
    # Step 2: Run installer
    printf "${GREEN}Step 2: Run Installation Script${NC}\n"
    simulate_command "sudo ./install-motd.sh" ""
    
    printf "${BLUE}[INFO]${NC} Creating backup of existing MOTD configuration...\n"
    printf "${CYAN}[INFO]${NC} Backed up /etc/update-motd.d to /root/motd-backup-20250721-021245\n"
    printf "${GREEN}[SUCCESS]${NC} Backup completed\n\n"
    
    printf "${BLUE}[INFO]${NC} Installing required packages...\n"
    printf "${CYAN}[INFO]${NC} Installing sysstat...\n"
    printf "${CYAN}[INFO]${NC} Installing net-tools...\n"
    printf "${CYAN}[INFO]${NC} Installing lsb-release...\n"
    printf "${GREEN}[SUCCESS]${NC} All dependencies installed\n\n"
    
    printf "${BLUE}[INFO]${NC} Installing custom MOTD script...\n"
    printf "${GREEN}[SUCCESS]${NC} MOTD script installed to /usr/local/bin/vps-sysinfo\n\n"
    
    printf "${BLUE}[INFO]${NC} Configuring MOTD settings...\n"
    printf "${CYAN}[INFO]${NC} Disabled 10-help-text\n"
    printf "${CYAN}[INFO]${NC} Disabled 50-motd-news\n"
    printf "${CYAN}[INFO]${NC} Disabled default header\n"
    printf "${GREEN}[SUCCESS]${NC} MOTD configuration completed\n\n"
    
    printf "${BLUE}[INFO]${NC} Testing MOTD installation...\n"
    printf "${GREEN}[SUCCESS]${NC} MOTD script executes successfully\n"
    printf "${GREEN}[SUCCESS]${NC} Installation test completed\n\n"
    
    printf "${GREEN}${WHITE}"
    printf "╔══════════════════════════════════════════════════════════════╗\n"
    printf "║                    INSTALLATION COMPLETE!                   ║\n"
    printf "╚══════════════════════════════════════════════════════════════╝\n"
    printf "${NC}\n"
    
    printf "${GREEN}[SUCCESS]${NC} TamsHub VPS MOTD has been successfully installed!\n"
    printf "${CYAN}[INFO]${NC} The new MOTD will be displayed on your next SSH login.\n"
    printf "${CYAN}[INFO]${NC} To test it now, run: sudo update-motd && cat /run/motd.dynamic\n"
    printf "${YELLOW}[INFO]${NC} To uninstall: sudo /usr/local/bin/uninstall-tamshub-vps-motd\n\n"
    
    # Step 3: Show sample output
    printf "${GREEN}Step 3: Preview of Your New MOTD${NC}\n"
    read -p "Press Enter to see what your new login screen will look like..."
    printf "\n"
    
    # Run the actual script to show the output
    ./vps-sysinfo.sh
    
    printf "\n${CYAN}This is what users will see when they SSH into your server!${NC}\n\n"
    
    # Final instructions
    printf "${WHITE}${BOLD}Ready to install for real?${NC}\n"
    printf "1. Run: ${CYAN}sudo ./install-motd.sh${NC}\n"
    printf "2. SSH into your server to see the new MOTD\n"
    printf "3. Enjoy your hardcore TamsHub VPS system information display!\n\n"
    
    printf "${YELLOW}Note: The actual installation requires root privileges and will:\n"
    printf "- Install system packages (sysstat, net-tools, etc.)\n"
    printf "- Modify MOTD configuration files\n"
    printf "- Create backup of existing MOTD files\n"
    printf "- Add custom scripts to /usr/local/bin/\n${NC}\n"
}

# Run the demo
demo_installation
