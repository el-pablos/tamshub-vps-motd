#!/bin/bash

# TamsHub VPS System Information Display Script
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
ARROW="▶"
BULLET="●"
SEPARATOR="━"
CORNER_TL="┌"
CORNER_TR="┐"
CORNER_BL="└"
CORNER_BR="┘"
HORIZONTAL="─"
VERTICAL="│"

# Function to create separator lines
create_separator() {
    local length=${1:-80}
    printf "${CYAN}"
    for ((i=1; i<=length; i++)); do
        printf "${SEPARATOR}"
    done
    printf "${NC}\n"
}

# Function to create bordered section header
section_header() {
    local title="$1"
    local length=80
    local title_length=${#title}
    local padding=$(( (length - title_length - 4) / 2 ))
    
    printf "${CYAN}${CORNER_TL}"
    for ((i=1; i<=length-2; i++)); do printf "${HORIZONTAL}"; done
    printf "${CORNER_TR}${NC}\n"
    
    printf "${CYAN}${VERTICAL}${NC}"
    for ((i=1; i<=padding; i++)); do printf " "; done
    printf "${WHITE}${BOLD}${title}${NC}"
    for ((i=1; i<=padding; i++)); do printf " "; done
    if (( title_length % 2 == 1 )); then printf " "; fi
    printf "${CYAN}${VERTICAL}${NC}\n"
    
    printf "${CYAN}${CORNER_BL}"
    for ((i=1; i<=length-2; i++)); do printf "${HORIZONTAL}"; done
    printf "${CORNER_BR}${NC}\n"
}

# Function to display key-value pairs with proper alignment
display_info() {
    local key="$1"
    local value="$2"
    local color="${3:-$WHITE}"
    printf "${GRAY}${BULLET} ${BOLD}%-25s${NC} ${color}%s${NC}\n" "$key:" "$value"
}

# Function to create progress bar
create_progress_bar() {
    local percentage="$1"
    local width=20

    # Convert percentage to integer if it's a decimal
    local percentage_int=$(echo "$percentage" | cut -d'.' -f1)
    if [ -z "$percentage_int" ] || [ "$percentage_int" = "" ]; then
        percentage_int=0
    fi

    local filled=$((percentage_int * width / 100))
    local empty=$((width - filled))

    printf "["
    # Filled portion
    for ((i=0; i<filled; i++)); do
        printf "${GREEN}█${NC}"
    done
    # Empty portion
    for ((i=0; i<empty; i++)); do
        printf "${GRAY}░${NC}"
    done
    printf "] ${BOLD}%3d%%${NC}" "$percentage_int"
}

# Function to display info with progress bar
display_info_with_bar() {
    local key="$1"
    local value="$2"
    local percentage="$3"
    local color="${4:-$WHITE}"

    printf "${GRAY}${BULLET} ${BOLD}%-25s${NC} ${color}%s${NC} " "$key:" "$value"
    create_progress_bar "$percentage"
    printf "\n"
}

# Function to create mini progress bar for table layout
create_mini_progress_bar() {
    local percentage="$1"
    local width=10

    # Convert percentage to integer if it's a decimal
    local percentage_int=$(echo "$percentage" | cut -d'.' -f1)
    if [ -z "$percentage_int" ] || [ "$percentage_int" = "" ]; then
        percentage_int=0
    fi

    local filled=$((percentage_int * width / 100))
    local empty=$((width - filled))

    printf "["
    # Filled portion
    for ((i=0; i<filled; i++)); do
        printf "${GREEN}█${NC}"
    done
    # Empty portion
    for ((i=0; i<empty; i++)); do
        printf "${GRAY}░${NC}"
    done
    printf "]"
}

# Function to get CPU information
get_cpu_info() {
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//')
    local cpu_cores=$(nproc --all)
    local cpu_threads=$(grep -c ^processor /proc/cpuinfo)
    local cpu_arch=$(uname -m)
    local cpu_freq=$(grep "cpu MHz" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//' | awk '{printf "%.2f GHz", $1/1000}')
    
    # Get CPU governor and scaling info
    local cpu_governor=""
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        cpu_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    fi
    
    echo "$cpu_model|$cpu_cores|$cpu_threads|$cpu_arch|$cpu_freq|$cpu_governor"
}

# Function to get memory information
get_memory_info() {
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')
    local mem_used=$(free -m | awk 'NR==2{printf "%.2f GB", ($2-$7)/1024}')
    local mem_cached=$(grep -E "^(Cached|Buffers)" /proc/meminfo | awk '{sum+=$2} END {printf "%.2f GB", sum/1024/1024}')
    local mem_usage_percent=$(free | awk 'NR==2{printf "%.1f%%", ($2-$7)/$2 * 100.0}')
    
    echo "$mem_total|$mem_available|$mem_used|$mem_cached|$mem_usage_percent"
}

# Function to get storage information
get_storage_info() {
    local root_usage=$(df -h / | awk 'NR==2 {print $2"|"$3"|"$4"|"$5}')
    local storage_type="Unknown"
    
    # Detect storage type
    if [ -d /sys/block ]; then
        for disk in /sys/block/*/queue/rotational; do
            if [ -f "$disk" ]; then
                local rotational=$(cat "$disk" 2>/dev/null)
                if [ "$rotational" = "0" ]; then
                    # Check if it's NVMe
                    local disk_name=$(echo "$disk" | cut -d'/' -f4)
                    if [[ "$disk_name" == nvme* ]]; then
                        storage_type="NVMe SSD"
                    else
                        storage_type="SSD"
                    fi
                    break
                else
                    storage_type="HDD"
                fi
            fi
        done
    fi
    
    echo "$root_usage|$storage_type"
}

# Function to get network information
get_network_info() {
    local primary_interface=$(ip route | grep default | awk '{print $5}' | head -1)
    local ip_address="Hidden for security"
    local interface_speed="Unknown"

    # Try to get interface speed
    if [ -f "/sys/class/net/$primary_interface/speed" ]; then
        local speed=$(cat "/sys/class/net/$primary_interface/speed" 2>/dev/null)
        if [ "$speed" != "-1" ] && [ -n "$speed" ]; then
            if [ "$speed" -ge 1000 ]; then
                interface_speed="$((speed/1000)) Gbps"
            else
                interface_speed="${speed} Mbps"
            fi
        fi
    fi

    echo "$primary_interface|$ip_address|$interface_speed"
}

# Function to get system performance metrics
get_performance_metrics() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local processes=$(ps aux | wc -l)
    local uptime_info=$(uptime -p | sed 's/up //')

    # Get disk I/O stats - use cumulative statistics instead of real-time
    local disk_io="N/A"
    if [ -f /proc/diskstats ]; then
        # Get the primary disk device (usually the first one with significant activity)
        local primary_disk=$(df / | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//' | sed 's|/dev/||')
        if [ -n "$primary_disk" ]; then
            # Get cumulative read/write sectors from /proc/diskstats
            local disk_stats=$(grep " $primary_disk " /proc/diskstats 2>/dev/null | head -1)
            if [ -n "$disk_stats" ]; then
                local read_sectors=$(echo "$disk_stats" | awk '{print $6}')
                local write_sectors=$(echo "$disk_stats" | awk '{print $10}')
                # Convert sectors to MB (assuming 512 bytes per sector)
                local read_mb=$((read_sectors * 512 / 1024 / 1024))
                local write_mb=$((write_sectors * 512 / 1024 / 1024))
                disk_io="Total R: ${read_mb} MB W: ${write_mb} MB"
            fi
        fi
    fi

    # Get network stats
    local net_stats="N/A"
    local primary_interface=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -f "/sys/class/net/$primary_interface/statistics/rx_bytes" ] && [ -f "/sys/class/net/$primary_interface/statistics/tx_bytes" ]; then
        local rx_bytes=$(cat "/sys/class/net/$primary_interface/statistics/rx_bytes")
        local tx_bytes=$(cat "/sys/class/net/$primary_interface/statistics/tx_bytes")
        local rx_mb=$((rx_bytes / 1024 / 1024))
        local tx_mb=$((tx_bytes / 1024 / 1024))
        net_stats="RX: ${rx_mb} MB TX: ${tx_mb} MB"
    fi

    echo "$load_avg|$cpu_usage|$processes|$uptime_info|$disk_io|$net_stats"
}

# Function to get system details
get_system_details() {
    local kernel_version=$(uname -r)
    local os_version=$(lsb_release -d 2>/dev/null | cut -d: -f2 | sed 's/^ *//' || echo "Ubuntu 22.04.5 LTS")
    local virtualization="Unknown"
    
    # Detect virtualization
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        virtualization=$(systemd-detect-virt 2>/dev/null || echo "Unknown")
        if [ "$virtualization" = "none" ]; then
            virtualization="Bare Metal"
        fi
    fi
    
    # Check for security features
    local security_features=""
    if [ -f /proc/version ]; then
        if grep -q "PREEMPT" /proc/version; then
            security_features="${security_features}PREEMPT "
        fi
    fi
    
    if [ -d /sys/kernel/security ]; then
        security_features="${security_features}LSM "
    fi
    
    if [ -z "$security_features" ]; then
        security_features="Standard"
    fi
    
    echo "$kernel_version|$os_version|$virtualization|$security_features"
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
    
    # Get all system information
    IFS='|' read -r cpu_model cpu_cores cpu_threads cpu_arch cpu_freq cpu_governor <<< "$(get_cpu_info)"
    IFS='|' read -r mem_total mem_available mem_used mem_cached mem_usage_percent <<< "$(get_memory_info)"
    IFS='|' read -r storage_total storage_used storage_available storage_percent storage_type <<< "$(get_storage_info)"
    IFS='|' read -r net_interface net_ip net_speed <<< "$(get_network_info)"
    IFS='|' read -r load_avg cpu_usage processes uptime_info disk_io net_stats <<< "$(get_performance_metrics)"
    IFS='|' read -r kernel_version os_version virtualization security_features <<< "$(get_system_details)"
    
    # Compact System Information Tables
    section_header "SYSTEM SPECIFICATIONS"
    printf "\n"

    # Hardware Table
    printf "${CYAN}${BOLD}HARDWARE${NC}\n"
    printf "${GRAY}┌─────────────────────────────────────────────────────────────────────────────┐${NC}\n"
    printf "${GRAY}│${NC} ${GREEN}CPU:${NC} %-35s ${YELLOW}Cores:${NC} %-8s ${CYAN}Freq:${NC} %-10s ${GRAY}│${NC}\n" \
           "$(echo "$cpu_model" | cut -c1-35)" "${cpu_cores}/${cpu_threads}" "$cpu_freq"

    # Extract percentage numbers for progress bars
    local mem_percent_num=$(echo "$mem_usage_percent" | sed 's/%//')
    local storage_percent_num=$(echo "$storage_percent" | sed 's/%//')

    printf "${GRAY}│${NC} ${GREEN}RAM:${NC} %-12s ${YELLOW}Used:${NC} %-12s " "$mem_total" "${mem_used} (${mem_usage_percent})"
    create_mini_progress_bar "$mem_percent_num"
    printf " ${GRAY}│${NC}\n"

    printf "${GRAY}│${NC} ${GREEN}Storage:${NC} %-8s ${YELLOW}Used:${NC} %-12s " "${storage_type} ${storage_total}" "${storage_used} (${storage_percent})"
    create_mini_progress_bar "$storage_percent_num"
    printf " ${GRAY}│${NC}\n"

    printf "${GRAY}│${NC} ${GREEN}Network:${NC} %-12s ${YELLOW}IP:${NC} %-20s ${CYAN}Speed:${NC} %-10s ${GRAY}│${NC}\n" \
           "$net_interface" "$net_ip" "$net_speed"
    printf "${GRAY}└─────────────────────────────────────────────────────────────────────────────┘${NC}\n"
    printf "\n"

    # Performance & System Table
    printf "${CYAN}${BOLD}PERFORMANCE & SYSTEM${NC}\n"
    printf "${GRAY}┌─────────────────────────────────────────────────────────────────────────────┐${NC}\n"
    printf "${GRAY}│${NC} ${GREEN}Uptime:${NC} %-20s ${YELLOW}Load:${NC} %-15s ${CYAN}CPU:${NC} %-8s ${GRAY}│${NC}\n" \
           "$uptime_info" "$load_avg" "${cpu_usage}%"
    printf "${GRAY}│${NC} ${GREEN}Processes:${NC} %-12s ${YELLOW}OS:${NC} %-25s ${CYAN}Kernel:${NC} %-10s ${GRAY}│${NC}\n" \
           "$processes" "$(echo "$os_version" | cut -c1-25)" "$(echo "$kernel_version" | cut -c1-10)"

    if [ "$net_stats" != "N/A" ]; then
        printf "${GRAY}│${NC} ${GREEN}Network:${NC} %-25s ${YELLOW}Virt:${NC} %-15s ${CYAN}Security:${NC} %-8s ${GRAY}│${NC}\n" \
               "$net_stats" "$virtualization" "$security_features"
    else
        printf "${GRAY}│${NC} ${GREEN}Virtualization:${NC} %-15s ${YELLOW}Security:${NC} %-25s ${GRAY}│${NC}\n" \
               "$virtualization" "$security_features"
    fi
    printf "${GRAY}└─────────────────────────────────────────────────────────────────────────────┘${NC}\n"
    printf "\n"
    
    create_separator
    
    # Footer
    printf "${GRAY}${BOLD}Last updated: $(TZ='Asia/Jakarta' date '+%Y-%m-%d %H:%M:%S %Z')${NC}\n"
    printf "${CYAN}${BOLD}Welcome to your TamsHub VPS high-performance environment!${NC}\n\n"
}

# Execute the main function
display_system_info
