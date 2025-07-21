#!/bin/bash

# TamsHub VPS Custom SSH Prompt Configuration
# Professional cyberpunk-inspired command prompt
# Author: Tamas (a.k.a. Pablos) - TamsHub
# Version: 1.0

# Color definitions for the prompt
PROMPT_CYAN='\[\033[0;36m\]'
PROMPT_BLUE='\[\033[0;34m\]'
PROMPT_GREEN='\[\033[0;32m\]'
PROMPT_YELLOW='\[\033[1;33m\]'
PROMPT_RED='\[\033[0;31m\]'
PROMPT_MAGENTA='\[\033[0;35m\]'
PROMPT_WHITE='\[\033[1;37m\]'
PROMPT_GRAY='\[\033[0;37m\]'
PROMPT_BOLD='\[\033[1m\]'
PROMPT_RESET='\[\033[0m\]'

# Function to get git branch if in a git repository
get_git_branch() {
    local branch
    if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
        if [[ $branch == "HEAD" ]]; then
            branch=$(git rev-parse --short HEAD 2>/dev/null)
        fi
        echo " ${PROMPT_MAGENTA}[${PROMPT_CYAN}git:${branch}${PROMPT_MAGENTA}]${PROMPT_RESET}"
    fi
}

# Function to get current load average
get_load_average() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    echo "${load}"
}

# Function to get memory usage percentage
get_memory_usage() {
    local mem_usage=$(free | awk 'NR==2{printf "%.0f", ($2-$7)/$2 * 100.0}')
    echo "${mem_usage}%"
}

# Function to determine prompt color based on last command exit status
get_status_color() {
    if [ $? -eq 0 ]; then
        echo "${PROMPT_GREEN}"
    else
        echo "${PROMPT_RED}"
    fi
}

# Function to get current time in HH:MM format
get_current_time() {
    date '+%H:%M'
}

# Function to create the main TamsHub VPS prompt
create_tamshub_prompt() {
    local exit_status=$?
    local status_color
    local git_info
    local load_avg
    local mem_usage
    local current_time

    # Get dynamic information
    if [ $exit_status -eq 0 ]; then
        status_color="${PROMPT_GREEN}"
    else
        status_color="${PROMPT_RED}"
    fi

    git_info=$(get_git_branch)
    load_avg=$(get_load_average)
    mem_usage=$(get_memory_usage)
    current_time=$(get_current_time)

    # Build the prompt using PS1 format
    PS1=""

    # First line: System info and time
    PS1+="${PROMPT_GRAY}┌─[${PROMPT_CYAN}${current_time}${PROMPT_GRAY}]─[${PROMPT_YELLOW}Load:${load_avg}${PROMPT_GRAY}]─[${PROMPT_BLUE}Mem:${mem_usage}${PROMPT_GRAY}]"

    # Add git info if available
    if [ -n "$git_info" ]; then
        PS1+="$git_info"
    fi

    PS1+="\n"

    # Second line: User, host, and path
    PS1+="${PROMPT_GRAY}├─[${PROMPT_CYAN}${PROMPT_BOLD}TamsHub${PROMPT_RESET}${PROMPT_GRAY}]─[${PROMPT_GREEN}\u${PROMPT_GRAY}@${PROMPT_BLUE}\h${PROMPT_GRAY}]─[${PROMPT_YELLOW}\w${PROMPT_GRAY}]\n"

    # Third line: Command prompt
    PS1+="${PROMPT_GRAY}└─${status_color}▶${PROMPT_RESET} "
}

# Function to create a simpler single-line prompt for narrow terminals
create_compact_prompt() {
    local exit_status=$?
    local status_color

    if [ $exit_status -eq 0 ]; then
        status_color="${PROMPT_GREEN}"
    else
        status_color="${PROMPT_RED}"
    fi

    PS1="${PROMPT_CYAN}[${PROMPT_BOLD}TamsHub${PROMPT_RESET}${PROMPT_CYAN}]${PROMPT_GRAY}─${PROMPT_GREEN}\u${PROMPT_GRAY}@${PROMPT_BLUE}\h${PROMPT_GRAY}:${PROMPT_YELLOW}\w${status_color}▶${PROMPT_RESET} "
}

# Function to set the appropriate prompt based on terminal width
set_dynamic_prompt() {
    local term_width=$(tput cols 2>/dev/null || echo 80)

    if [ "$term_width" -lt 100 ]; then
        # Use compact prompt for narrow terminals
        create_compact_prompt
    else
        # Use full multi-line prompt for wider terminals
        create_tamshub_prompt
    fi
}

# Function to set window title for supported terminals
set_window_title() {
    case "$TERM" in
        xterm*|rxvt*|screen*|tmux*)
            echo -ne "\033]0;TamsHub VPS - \u@\h:\w\007"
            ;;
    esac
}

# Main prompt setup function
setup_tamshub_prompt() {
    # Set the prompt command to update dynamically
    PROMPT_COMMAND='set_dynamic_prompt; set_window_title'
    
    # Set initial prompt
    set_dynamic_prompt
    
    # Configure history
    export HISTSIZE=10000
    export HISTFILESIZE=20000
    export HISTCONTROL=ignoredups:erasedups
    
    # Enable color support for ls and other commands
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
    
    # Add some useful aliases for TamsHub VPS management
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias sysinfo='/usr/local/bin/vps-sysinfo 2>/dev/null || echo "TamsHub VPS MOTD not installed. Run: sudo ./install-motd.sh"'
    alias tamshub-status='systemctl status --no-pager'
    alias tamshub-logs='journalctl -f'
    
    # Welcome message (only for interactive shells and not in MOTD context)
    if [[ $- == *i* ]] && [[ -z "$MOTD_SHOWN" ]]; then
        echo -e "\033[0;36m\033[1mTamsHub VPS\033[0m \033[0;37mProfessional Command Environment\033[0m"
        echo -e "\033[0;37mType \033[1;33m'sysinfo'\033[0;37m to view system information\033[0m"
        export MOTD_SHOWN=1
    fi
}

# Auto-setup if sourced directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced, not executed directly."
    echo "Add 'source /path/to/custom-prompt.sh' to your ~/.bashrc"
    exit 1
else
    setup_tamshub_prompt
fi
