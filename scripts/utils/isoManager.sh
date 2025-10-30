#!/bin/bash
# ISO Manager Wrapper Script
# Location: TuxTechIaaC/scripts/utils/isoManager.sh

# Get the root directory of the repository
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
PY_SCRIPT="$REPO_ROOT/core/iso_manager/iso_manager.py"
REQUIREMENTS="$REPO_ROOT/core/iso_manager/requirements.txt"

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed. Please install Python 3 and try again."
    exit 1
fi

# Check if pip is available
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is required but not installed. Please install pip3 and try again."
    exit 1
fi

# Function to install requirements
install_requirements() {
    echo "🔧 Installing/updating Python dependencies..."
    if ! pip3 install --user -r "$REQUIREMENTS"; then
        echo "❌ Failed to install requirements. Trying with --break-system-packages..."
        pip3 install --user --break-system-packages -r "$REQUIREMENTS" || {
            echo "❌ Failed to install requirements. Please check your Python/pip setup."
            exit 1
        }
    fi
}

# Function to run the ISO manager
run_iso_manager() {
    # Check if the Python script exists
    if [ ! -f "$PY_SCRIPT" ]; then
        echo "❌ ISO Manager script not found at: $PY_SCRIPT"
        exit 1
    fi

    # Check if requirements are installed
    if ! python3 -c "import rich, yaml, requests" &> /dev/null; then
        install_requirements
    fi

    # Run the ISO manager
    echo "---------------------------------------"
    echo "       TuxTechIaaC : isoManager"
    echo "---------------------------------------"
    echo "🚀 Starting "
    echo 
    python3 "$PY_SCRIPT" "$@"
}

# Main execution
main() {
    case "$1" in
        install)
            install_requirements
            ;;
        *)
            run_iso_manager "$@"
            ;;
    esac
}

# Run the main function
main "$@"