#!/bin/bash

# Text Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold Text Colors
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Background Colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Reset Color
NC='\033[0m' # No Color

# Function to print colored text
print_color() {
    local color=$1
    local message=$2
    local newline=$3
    
    # Default to adding a newline if not specified
    if [ -z "$newline" ]; then
        newline=true
    fi
    
    case $color in
        "Black") color_code=$BLACK ;;
        "Red") color_code=$RED ;;
        "Green") color_code=$GREEN ;;
        "Yellow") color_code=$YELLOW ;;
        "Blue") color_code=$BLUE ;;
        "Magenta") color_code=$MAGENTA ;;
        "Cyan") color_code=$CYAN ;;
        "White") color_code=$WHITE ;;
        "BBlack") color_code=$BOLD_BLACK ;;
        "BRed") color_code=$BOLD_RED ;;
        "BGreen") color_code=$BOLD_GREEN ;;
        "BYellow") color_code=$BOLD_YELLOW ;;
        "BBlue") color_code=$BOLD_BLUE ;;
        "BMagenta") color_code=$BOLD_MAGENTA ;;
        "BCyan") color_code=$BOLD_CYAN ;;
        "BWhite") color_code=$BOLD_WHITE ;;
        *) color_code=$NC ;;
    esac
    
    if [ "$newline" = true ]; then
        echo -e "${color_code}${message}${NC}"
    else
        echo -ne "${color_code}${message}${NC}"
    fi
}

# Function to print a header
print_header() {
    local message=$1
    local length=${#message}
    local line=$(printf '%*s' $length | tr ' ' '=')
    
    echo -e "\n${BOLD_BLUE}${line}${NC}"
    print_color "BBlue" "${message}"
    echo -e "${BOLD_BLUE}${line}${NC}\n"
}

# Function to print a success message
print_success() {
    print_color "BGreen" "[✓] $1"
}

# Function to print an error message
print_error() {
    print_color "BRed" "[✗] $1"
}

# Function to print a warning message
print_warning() {
    print_color "BYellow" "[!] $1"
}

# Function to print an info message
print_info() {
    print_color "BCyan" "[i] $1"
}

# Function to print a debug message (only if DEBUG is set to true)
print_debug() {
    if [ "$DEBUG" = true ]; then
        print_color "BMagenta" "[DEBUG] $1"
    fi
}

# Function to print a progress bar
# Usage: progress_bar <current> <total> [width]
progress_bar() {
    local current=$1
    local total=$2
    local width=${3:-50}  # Default width: 50 characters
    
    # Calculate percentage
    local percent=$((current * 100 / total))
    
    # Calculate progress bar length
    local progress=$((current * width / total))
    
    # Create the progress bar string
    local bar=""
    for ((i=0; i<width; i++)); do
        if [ $i -lt $progress ]; then
            bar+="#"
        else
            bar+=" "
        fi
    done
    
    # Print the progress bar
    printf "\r[%-${width}s] %d%%" "$bar" "$percent"
    
    # Add a newline if complete
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Export the functions
export -f print_color print_header print_success print_error print_warning print_info print_debug progress_bar
