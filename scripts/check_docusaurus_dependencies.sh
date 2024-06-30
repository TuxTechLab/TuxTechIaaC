#!/bin/bash

# Required versions
REQUIRED_NODE_VERSION="v20.15.0"
REQUIRED_NPM_VERSION="10.7.0"
REQUIRED_NPX_VERSION="10.7.0"
REQUIRED_DOCUSAURUS_VERSION="3.4.0"
REQUIRED_NPM_PACKAGE="@docusaurus/core"

# Help function
help() {
    echo "Usage: $0 [--help]"
    echo "Checks if the required dependencies are met for running Docusaurus."
    echo
    echo "Options:"
    echo "  --help   Display this help message"
    exit 0
}

# Function to compare versions
version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# Check Node.js version
check_node_version() {
    NODE_VERSION=$(node -v)
    if version_ge "$NODE_VERSION" "$REQUIRED_NODE_VERSION"; then
        echo "Node.js version is $NODE_VERSION (required: $REQUIRED_NODE_VERSION or above)"
    else
        echo "Node.js version is $NODE_VERSION, which is less than the required version $REQUIRED_NODE_VERSION"
        exit 1
    fi
}

# Check npm version
check_npm_version() {
    NPM_VERSION=$(npm -v)
    if version_ge "$NPM_VERSION" "$REQUIRED_NPM_VERSION"; then
        echo "npm version is $NPM_VERSION (required: $REQUIRED_NPM_VERSION or above)"
    else
        echo "npm version is $NPM_VERSION, which is less than the required version $REQUIRED_NPM_VERSION"
        exit 1
    fi
}

# Check npx version
check_npx_version() {
    NPX_VERSION=$(npx -v)
    if version_ge "$NPX_VERSION" "$REQUIRED_NPX_VERSION"; then
        echo "npx version is $NPX_VERSION (required: $REQUIRED_NPX_VERSION or above)"
    else
        echo "npx version is $NPX_VERSION, which is less than the required version $REQUIRED_NPX_VERSION"
        exit 1
    fi
}

check_docusaurus_version(){
    DOCUSAURUS_VERSION=$(cd ../www/tuxtechiaac/ && npx docusaurus -V)
    if version_ge "$DOCUSAURUS_VERSION" "$REQUIRED_DOCUSAURUS_VERSION"; then
        echo "Docusaurus Version is $DOCUSAURUS_VERSION (required: $REQUIRED_DOCUSAURUS_VERSION)"
    else
        echo "Docusaurus is either not installed or having issues, (required) $REQUIRED_DOCUSAURUS_VERSION"
        echo "Printing : www/tuxtechiaac/package.json"
        echo ""
        echo "-----------------------------------------"
        cat "../www/tuxtechiaac/package.json"
        echo "-----------------------------------------"
        echo "Please check: https://docusaurus.io/docs/installation."
        exit 1
    fi
}

check_docusaurus_installed() {
    # Change directory to the Docusaurus project
    cd ../www/tuxtechiaac

    # Check if Docusaurus is installed
    if npm ls --depth 1 | grep -q '@docusaurus/core'; then
        DOCUSAURUS_VERSION=$(npm ls @docusaurus/core --depth 0 | grep @docusaurus/core | awk -F'@' '{print $3}')
        echo "Docusaurus Version is $DOCUSAURUS_VERSION (required: $REQUIRED_DOCUSAURUS_VERSION)"
    else
        echo "Docusaurus is either not installed or having issues, (required) $REQUIRED_DOCUSAURUS_VERSION"
        echo "Printing: ../www/tuxtechiaac/package.json"
        echo ""
        echo "-----------------------------------------"
        cat "../www/tuxtechiaac/package.json"
        echo "-----------------------------------------"
        echo "Please check: https://docusaurus.io/docs/installation."
        exit 1
    fi

    # Change back to the original directory
    cd - > /dev/null
}

# Main function
main() {
    # Parse command line arguments
    if [[ "$1" == "--help" ]]; then
        help
    fi

    check_node_version || exit 1
    check_npm_version  || exit 1
    check_npx_version  || exit 1
    check_docusaurus_version || exit 1
    check_docusaurus_installed || exit 1
    echo "Passed : Dependency Check | TuxTechIaaC Docusaurus Website"
    echo "Next To Start Server view ./manage_docusaurus_server.sh --help"
    exit 0
}

# Call the main function with command line arguments
main "$@"