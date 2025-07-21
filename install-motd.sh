#!/bin/bash

# MOTD Installation Script for TamsHub VPS System Information Display
# This script installs and configures the custom MOTD for Ubuntu 22.04.5 LTS
# Author: Tamas (a.k.a. Pablos) - TamsHub

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color="$1"
    local message="$2"
    printf "${color}[INFO]${NC} %s\n" "$message"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Backup existing MOTD files
backup_motd() {
    print_status "$BLUE" "Creating backup of existing MOTD configuration..."
    
    local backup_dir="/root/motd-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup existing MOTD files
    if [ -d "/etc/update-motd.d" ]; then
        cp -r /etc/update-motd.d "$backup_dir/"
        print_status "$CYAN" "Backed up /etc/update-motd.d to $backup_dir"
    fi
    
    if [ -f "/etc/motd" ]; then
        cp /etc/motd "$backup_dir/"
        print_status "$CYAN" "Backed up /etc/motd to $backup_dir"
    fi
    
    print_success "Backup completed: $backup_dir"
}

# Install required packages
install_dependencies() {
    print_status "$BLUE" "Installing required packages..."
    
    # Update package list
    apt-get update -qq
    
    # Install required packages
    local packages=(
        "sysstat"      # For iostat command
        "net-tools"    # For network statistics
        "lsb-release"  # For OS version detection
        "curl"         # For network testing
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            print_status "$CYAN" "Installing $package..."
            apt-get install -y "$package" >/dev/null 2>&1
        else
            print_status "$CYAN" "$package is already installed"
        fi
    done
    
    print_success "All dependencies installed"
}

# Install the custom MOTD script
install_motd_script() {
    print_status "$BLUE" "Installing custom MOTD script..."
    
    # Copy the main script
    if [ ! -f "vps-sysinfo.sh" ]; then
        print_error "vps-sysinfo.sh not found in current directory"
        exit 1
    fi
    
    # Install the script
    cp vps-sysinfo.sh /usr/local/bin/vps-sysinfo
    chmod +x /usr/local/bin/vps-sysinfo
    
    # Create MOTD script
    cat > /etc/update-motd.d/01-tamshub-vps << 'EOF'
#!/bin/bash
# Custom TamsHub VPS System Information Display
/usr/local/bin/vps-sysinfo
EOF

    chmod +x /etc/update-motd.d/01-tamshub-vps
    
    print_success "MOTD script installed to /usr/local/bin/vps-sysinfo"
}

# Disable default Ubuntu MOTD components
configure_motd() {
    print_status "$BLUE" "Configuring MOTD settings..."
    
    # Disable default MOTD components that we don't want
    local motd_scripts=(
        "10-help-text"
        "50-motd-news"
        "80-esm"
        "95-hwe-eol"
    )
    
    for script in "${motd_scripts[@]}"; do
        if [ -f "/etc/update-motd.d/$script" ]; then
            chmod -x "/etc/update-motd.d/$script"
            print_status "$CYAN" "Disabled $script"
        fi
    done
    
    # Keep some useful default scripts but rename them to run after ours
    if [ -f "/etc/update-motd.d/00-header" ]; then
        mv /etc/update-motd.d/00-header /etc/update-motd.d/00-header.disabled
        print_status "$CYAN" "Disabled default header"
    fi
    
    # Disable last login message
    if [ -f "/etc/ssh/sshd_config" ]; then
        if ! grep -q "PrintLastLog no" /etc/ssh/sshd_config; then
            echo "PrintLastLog no" >> /etc/ssh/sshd_config
            print_status "$CYAN" "Disabled last login message"
            systemctl reload ssh
        fi
    fi
    
    print_success "MOTD configuration completed"
}

# Test the installation
test_installation() {
    print_status "$BLUE" "Testing MOTD installation..."
    
    # Test the script execution
    if /usr/local/bin/vps-sysinfo >/dev/null 2>&1; then
        print_success "MOTD script executes successfully"
    else
        print_error "MOTD script execution failed"
        exit 1
    fi
    
    # Update MOTD cache
    update-motd
    
    print_success "Installation test completed"
}

# Create uninstall script
create_uninstall_script() {
    print_status "$BLUE" "Creating uninstall script..."
    
    cat > /usr/local/bin/uninstall-tamshub-vps-motd << 'EOF'
#!/bin/bash
# Uninstall script for TamsHub VPS MOTD

echo "Uninstalling TamsHub VPS MOTD..."

# Remove custom MOTD script
rm -f /etc/update-motd.d/01-tamshub-vps
rm -f /usr/local/bin/vps-sysinfo

# Re-enable default MOTD components
chmod +x /etc/update-motd.d/10-help-text 2>/dev/null || true
chmod +x /etc/update-motd.d/50-motd-news 2>/dev/null || true
chmod +x /etc/update-motd.d/80-esm 2>/dev/null || true
chmod +x /etc/update-motd.d/95-hwe-eol 2>/dev/null || true

# Restore header if it exists
if [ -f "/etc/update-motd.d/00-header.disabled" ]; then
    mv /etc/update-motd.d/00-header.disabled /etc/update-motd.d/00-header
fi

# Update MOTD
update-motd

echo "TamsHub VPS MOTD uninstalled successfully"
echo "To restore from backup, check /root/motd-backup-* directories"
EOF

    chmod +x /usr/local/bin/uninstall-tamshub-vps-motd
    print_success "Uninstall script created: /usr/local/bin/uninstall-tamshub-vps-motd"
}

# Main installation function
main() {
    printf "${CYAN}${WHITE}\n"
    printf "╔══════════════════════════════════════════════════════════════╗\n"
    printf "║                   TAMSHUB VPS MOTD INSTALLER                 ║\n"
    printf "║              Professional System Information Display         ║\n"
    printf "╚══════════════════════════════════════════════════════════════╝\n"
    printf "${NC}\n"

    print_status "$WHITE" "Starting TamsHub VPS MOTD installation..."
    
    # Run installation steps
    check_root
    backup_motd
    install_dependencies
    install_motd_script
    configure_motd
    test_installation
    create_uninstall_script
    
    printf "\n${GREEN}${WHITE}"
    printf "╔══════════════════════════════════════════════════════════════╗\n"
    printf "║                    INSTALLATION COMPLETE!                   ║\n"
    printf "╚══════════════════════════════════════════════════════════════╝\n"
    printf "${NC}\n"
    
    print_success "TamsHub VPS MOTD has been successfully installed!"
    print_status "$CYAN" "The new MOTD will be displayed on your next SSH login."
    print_status "$CYAN" "To test it now, run: sudo update-motd && cat /run/motd.dynamic"
    print_status "$YELLOW" "To uninstall: sudo /usr/local/bin/uninstall-tamshub-vps-motd"

    printf "\n${CYAN}Enjoy your new hardcore TamsHub VPS system information display!${NC}\n\n"
}

# Run the installer
main "$@"
