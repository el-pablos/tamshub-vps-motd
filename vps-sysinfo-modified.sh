#!/bin/bash

# TamsHub VPS System Information Display Script (Modified - No System Info)
# Professional MOTD for Ubuntu 22.04.5 LTS
# Author: Tamas (a.k.a. Pablos)
# Organization: TamsHub
# Version: 2.0

# Color definitions for professional display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Unicode characters for professional display
SEPARATOR="━"

# Function to create separator lines
create_separator() {
    local length=${1:-80}
    printf "${CYAN}"
    for ((i=1; i<=length; i++)); do
        printf "${SEPARATOR}"
    done
    printf "${NC}\n"
}

# Main display function
display_system_info() {
    clear
    
    # Header with ASCII art
    printf "${CYAN}${BOLD}\n"
    printf "   ████████╗ █████╗ ███╗   ███╗███████╗██╗  ██╗██╗   ██╗██████╗     ██╗   ██╗██████╗ ███████╗\n"
    printf "   ╚══██╔══╝██╔══██╗████╗ ████║██╔════╝██║  ██║██║   ██║██╔══██╗    ██║   ██║██╔══██╗██╔════╝\n"
    printf "      ██║   ███████║██╔████╔██║███████╗███████║██║   ██║██████╔╝    ██║   ██║██████╔╝███████╗\n"
    printf "      ██║   ██╔══██║██║╚██╔╝██║╚════██║██╔══██║██║   ██║██╔══██╗    ╚██╗ ██╔╝██╔═══╝ ╚════██║\n"
    printf "      ██║   ██║  ██║██║ ╚═╝ ██║███████║██║  ██║╚██████╔╝██████╔╝     ╚████╔╝ ██║     ███████║\n"
    printf "      ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝       ╚═══╝  ╚═╝     ╚══════╝\n"
    printf "${NC}\n"
    
    printf "${WHITE}${BOLD}                    ELITE VIRTUAL PRIVATE SERVER${NC}\n"
    printf "${GRAY}                        High-Performance Computing Platform${NC}\n"
    printf "${YELLOW}                           Author: Tamas (a.k.a. Pablos)${NC}\n"
    printf "${CYAN}                              Organization: TamsHub${NC}\n\n"
    
    create_separator
    
    # Footer
    printf "${GRAY}${BOLD}Last updated: $(TZ='Asia/Jakarta' date '+%Y-%m-%d %H:%M:%S %Z')${NC}\n"
    printf "${CYAN}${BOLD}Welcome to your TamsHub VPS high-performance environment!${NC}\n\n"
}

# Execute the main function
display_system_info
