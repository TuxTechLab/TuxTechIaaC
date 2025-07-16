#!/bin/bash

# Import Terminal Colors
if [ -f "./colors.sh" ]; then
    source ./colors.sh
else
    # Fallback colors if colors.sh is not available
    print_info() { echo "[i] $1"; }
    print_success() { echo "[✓] $1"; }
    print_warning() { echo "[!] $1"; }
    print_error() { echo "[✗] $1"; }
    print_debug() { [ "$DEBUG" = "1" ] && echo "[DEBUG] $1" >&2; }
fi

# Function to clean version string (remove any non-numeric and non-dot characters)
clean_version() {
    local version="$1"
    
    # If input is empty, return error
    if [ -z "$version" ]; then
        print_debug "clean_version: Input version is empty"
        echo ""
        return 1
    fi
    
    # Remove any non-numeric and non-dot characters
    version=$(echo "$version" | tr -cd '0-9.')
    
    # Remove leading/trailing dots and multiple consecutive dots
    version=$(echo "$version" | sed -e 's/^\.*//' -e 's/\.*$//' -e 's/\.\.*/./g')
    
    # If empty after cleaning, return error
    if [ -z "$version" ]; then
        print_debug "clean_version: Version is empty after cleaning"
        echo ""
        return 1
    fi
    
    # Ensure we have at least one dot (X.Y)
    if ! [[ "$version" =~ \. ]]; then
        version="${version}.0"
    fi
    
    # Split into parts
    local IFS=.
    local parts=($version)
    
    # Ensure we have at least two parts (X.Y)
    if [ ${#parts[@]} -lt 2 ]; then
        version="${version}.0"
        parts=(${version//./ })
    fi
    
    # Ensure we don't have more than 3 parts (X.Y.Z)
    if [ ${#parts[@]} -gt 3 ]; then
        version=$(echo "$version" | cut -d. -f1-3)
        parts=(${version//./ })
    fi
    
    # Ensure each part is a valid number
    for part in "${parts[@]}"; do
        if ! [[ "$part" =~ ^[0-9]+$ ]]; then
            print_debug "clean_version: Invalid version part: '$part'"
            echo ""
            return 1
        fi
    done
    
    # Reconstruct the version string
    version=$(IFS=.; echo "${parts[*]}")
    
    # Final validation
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        print_debug "clean_version: Invalid version format after cleaning: '$version'"
        echo ""
        return 1
    fi
    
    print_debug "clean_version: Cleaned '$1' -> '$version'"
    echo "$version"
    return 0
}

# Configuration
DEVICE_MODEL="Archer C6 v3"
FIRMWARE_DIR="./openwrt-firmware"
DOWNLOAD_DIR="${FIRMWARE_DIR}/downloads"

# Create necessary directories
mkdir -p "${FIRMWARE_DIR}" "${DOWNLOAD_DIR}"

# Function to show usage
show_help() {
    echo "Usage: $0 [OPTIONS] [VERSION]"
    echo "Check for OpenWrt firmware updates for ${DEVICE_MODEL}"
    echo
    echo "Options:"
    echo "  -c, --check-only    Only check for updates, don't download"
    echo "  -d, --download      Download the latest firmware if update is available"
    echo "  -f, --force         Force download even if versions match"
    echo "  -h, --help          Show this help message"
    echo
    echo "VERSION: Optional. Specify current OpenWrt version (e.g., 24.10.0)"
    echo "         If not provided, you will be prompted to enter it."
    echo
    echo "Examples:"
    echo "  $0 -c 24.10.0       Check for updates for version 24.10.0"
    echo "  $0 -d 24.10.0       Download update for version 24.10.0"
    echo "  $0 -f 24.10.0       Force download for version 24.10.0"
    echo "  $0 -d               Will prompt for version"
    exit 0
}

# Parse command line arguments
CHECK_ONLY=false
FORCE=false
DOWNLOAD=false
VERSION_ARG=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--check)
            CHECK_ONLY=true
            shift
            ;;
        -d|--download)
            DOWNLOAD=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # If it's not an option, it's the version
            if [ -z "$VERSION_ARG" ]; then
                VERSION_ARG="$1"
                # Clean the version immediately to validate it
                if ! CLEAN_VERSION=$(clean_version "$VERSION_ARG"); then
                    print_error "Invalid version format: '$VERSION_ARG'"
                    exit 1
                fi
                VERSION_ARG="$CLEAN_VERSION"
            else
                echo "Error: Multiple version arguments provided"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Set default action if no operation specified
if [ "$CHECK_ONLY" = false ] && [ "$DOWNLOAD" = false ] && [ "$FORCE" = false ]; then
    CHECK_ONLY=true  # Default to check-only mode
fi

# Get current version
if [ -z "$VERSION_ARG" ]; then
    read -p "Enter your current OpenWrt version (e.g., 24.10.0): " CURRENT_VERSION
else
    CURRENT_VERSION="$VERSION_ARG"
fi

# Clean the version string
CURRENT_VERSION=$(clean_version "$CURRENT_VERSION")

if [ -z "$CURRENT_VERSION" ]; then
    print_error "Invalid version format. Please use X.Y.Z format (e.g., 24.10.0)"
    exit 1
fi

print_info "Checking for updates for OpenWrt version: $CURRENT_VERSION"

# Function to get latest firmware version from OpenWrt website
get_latest_version() {
    local url="https://downloads.openwrt.org/releases/"
    local latest_version
    
    # Use curl to get the latest version
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        return 1
    fi
    
    # Get the releases page with a 10-second timeout
    local response
    response=$(curl -s -f --connect-timeout 10 "$url" 2>&1)
    
    if [ $? -ne 0 ]; then
        print_error "Failed to connect to OpenWrt releases page: $response"
        return 1
    fi
    
    # Extract all version numbers from the page
    local versions=$(echo "$response" | grep -oP 'href="\K[0-9]+\.[0-9]+(\.[0-9]+)?(?=/)' | sort -V)
    
    if [ -z "$versions" ]; then
        # Try alternative pattern if first one fails
        versions=$(echo "$response" | grep -oP 'releases/\K[0-9]+\.[0-9]+(\.[0-9]+)?' | sort -V)
    fi
    
    if [ -z "$versions" ]; then
        print_error "Could not find any version numbers on the releases page"
        return 1
    fi
    
    # Get the latest version (last in the sorted list)
    latest_version=$(echo "$versions" | tail -n 1)
    
    # Ensure version has three parts (X.Y.Z)
    if ! [[ "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        latest_version="${latest_version}.0"
    fi
    
    # Verify this is a valid version (e.g., 24.10.2)
    if ! [[ "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format retrieved: $latest_version"
        return 1
    fi
    
    # Only output the version number (no debug info)
    echo "$latest_version"
    return 0
}

# Function to download firmware using curl
download_firmware() {
    local version=$1
    
    # Clean the version string thoroughly
    version=$(clean_version "$version")
    
    if [ -z "$version" ]; then
        print_error "Invalid version format"
        return 1
    fi
    
    local base_url="https://downloads.openwrt.org/releases"
    local target="ramips/mt7621"
    local filename="openwrt-${version}-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin"
    local url="${base_url}/${version}/targets/${target}/${filename}"
    
    # Clean the URL of any remaining control characters
    url=$(echo "$url" | tr -d '[:cntrl:]' | tr -d ' ')
    
    # Create download directory if it doesn't exist
    mkdir -p "$DOWNLOAD_DIR"
    local output_file="${DOWNLOAD_DIR}/${filename}"
    
    # Clear any previous output
    echo -ne "\r\033[K"
    
    print_info "Preparing to download firmware..."
    print_info "Version: ${version}"
    print_success "URL: ${url}"
    print_info "Saving to: $(realpath $output_file)"
    
    # Check if file already exists
    if [ -f "$output_file" ]; then
        print_warning "File already exists: $output_file"
        read -p "Do you want to overwrite? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Download cancelled by user"
            return 0
        fi
    fi
    
    # Download the file with progress
    print_info "Starting download..."
    if ! curl -L --progress-bar -o "$output_file" "$url"; then
        print_error "Download failed"
        # Clean up partially downloaded file if any
        [ -f "$output_file" ] && rm -f "$output_file"
        return 1
    fi
    
    # Verify download
    if [ -f "$output_file" ]; then
        local file_size=$(du -h "$output_file" | cut -f1)
        print_success "Download completed successfully"
        print_info "File: $filename"
        print_info "Size: $file_size"
        print_info "Location: `realpath $output_file`"
        return 0
    else
        print_error "Download completed but file not found"
        return 1
    fi
}

# Function to compare version numbers
# Returns: 0 if versions are equal, 1 if first is greater, 2 if second is greater
version_compare() {
    # Clean and validate input versions
    local ver1=$(clean_version "$1")
    local ver2=$(clean_version "$2")
    
    # Debug output
    print_debug "Comparing versions: '$1' -> '$ver1' vs '$2' -> '$ver2'"
    
    # If either version is empty after cleaning, it's invalid
    if [ -z "$ver1" ]; then
        print_error "First version is empty after cleaning: '$1'"
        return 3
    fi
    
    if [ -z "$ver2" ]; then
        print_error "Second version is empty after cleaning: '$2'"
        return 3
    fi
    
    # Quick check if versions are exactly the same
    if [ "$ver1" = "$ver2" ]; then
        print_debug "Versions are exactly equal"
        return 0
    fi
    
    # Split versions into parts
    local IFS=.
    local i
    local ver1_parts=($ver1)
    local ver2_parts=($ver2)
    
    # Debug output
    print_debug "Version 1 parts: ${ver1_parts[*]}"
    print_debug "Version 2 parts: ${ver2_parts[*]}"
    
    # Find the maximum number of parts between the two versions
    local max_length=$(( ${#ver1_parts[@]} > ${#ver2_parts[@]} ? ${#ver1_parts[@]} : ${#ver2_parts[@]} ))
    
    # Compare each part
    for ((i=0; i<max_length; i++)); do
        # Get current part or default to 0 if not present
        local part1=${ver1_parts[i]:-0}
        local part2=${ver2_parts[i]:-0}
        
        # Remove any non-numeric characters
        part1=${part1//[^0-9]/}
        part2=${part2//[^0-9]/}
        
        # Default to 0 if empty after cleaning
        part1=${part1:-0}
        part2=${part2:-0}
        
        # Convert to base 10 numbers for comparison
        part1=$((10#$part1))
        part2=$((10#$part2))
        
        # Compare the numeric parts
        if (( part1 > part2 )); then
            print_debug "$1 > $2 (part $i: $part1 > $part2)"
            return 1
        elif (( part1 < part2 )); then
            print_debug "$1 < $2 (part $i: $part1 < $part2)"
            return 2
        fi
    done
    
    # If we get here, all compared parts were equal
    print_debug "Versions are equal after all parts compared"
    return 0
}

# Main function
main() {
    # Enable debug output if DEBUG=1
    [ "$DEBUG" = "1" ] && set -x
    
    # Get current version
    if [ -n "$VERSION_ARG" ]; then
        # Use the version provided as argument (already cleaned during argument parsing)
        CURRENT_VERSION="$VERSION_ARG"
        print_info "Using provided version: $CURRENT_VERSION"
    else
        # Interactive mode: ask for version
        while true; do
            # Get current version
            if [ -z "$CURRENT_VERSION" ]; then
                read -p "Enter your current OpenWrt version (e.g., 24.10.0): " CURRENT_VERSION
            fi
            CURRENT_VERSION=$(clean_version "$CURRENT_VERSION")
            if [ -n "$CURRENT_VERSION" ]; then
                break
            fi
            print_error "Invalid version format. Please use X.Y.Z format (e.g., 24.10.0)"
        done
    fi
    
    # Get latest version
    print_info "Fetching latest version information..."
    LATEST_VERSION=$(get_latest_version)
    local ret=$?
    
    if [ $ret -ne 0 ]; then
        print_error "Failed to check for updates (error code: $ret)"
        exit 1
    fi
    
    # Clean the version string
    LATEST_VERSION=$(clean_version "$LATEST_VERSION")
    
    if [ -z "$LATEST_VERSION" ]; then
        print_error "Failed to determine latest version"
        exit 1
    fi
    
    print_warning "Latest available version: $LATEST_VERSION"
    
    # Compare versions with debug output
    print_debug "Comparing versions: Current=$CURRENT_VERSION, Latest=$LATEST_VERSION"
    version_compare "$CURRENT_VERSION" "$LATEST_VERSION"
    local compare_result=$?
    
    case $compare_result in
        0) 
            STATUS="up to date"
            UPDATE_AVAILABLE=0
            print_debug "Versions are the same"
            ;;
        1) 
            STATUS="newer than latest"
            UPDATE_AVAILABLE=0
            print_debug "Current version is newer than latest"
            ;;
        2) 
            STATUS="update available"
            UPDATE_AVAILABLE=1
            print_debug "Update available"
            ;;
        *) 
            STATUS="version comparison failed"
            UPDATE_AVAILABLE=0
            print_error "Version comparison failed with code $compare_result"
            ;;
    esac
    
    # Display results
    echo
    echo "====================OpenWrt Update Check===================="
    echo
    echo "Device                : $DEVICE_MODEL"
    echo
    print_success "Current version   : $CURRENT_VERSION"
    print_info "Latest version    : $LATEST_VERSION"
    print_warning "Old Firmware      : $STATUS"
    
    if [ $UPDATE_AVAILABLE -eq 1 ]; then
        echo
        print_success "$STATUS"
        echo
        
    if [ "$CHECK_ONLY" = true ]; then
            echo "Run with -d to download the update"
            exit 0
        fi
        
        if [ "$DOWNLOAD" = true ] || [ "$FORCE" = true ]; then
            echo "Downloading update..."
            download_firmware "$LATEST_VERSION"
            exit $?
        else
            read -p "Do you want to download OpenWrt $LATEST_VERSION? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                download_firmware "$LATEST_VERSION"
                exit $?
            fi
        fi
    else
        if [ "$FORCE" = true ]; then
            print_warning "Forcing download of version $LATEST_VERSION"
            download_firmware "$LATEST_VERSION"
            exit $?
        else
            if [ "$compare_result" -eq 0 ]; then
                print_success "You are already running the latest version"
            else
                print_warning "You are running a newer version ($CURRENT_VERSION) than the latest available ($LATEST_VERSION)"
            fi
        fi
    fi
}

# Only execute if script is run directly, not sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    # Execute main function with all arguments
    main "$@"
fi
