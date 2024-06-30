#!/bin/bash

# Path to check_dependencies.sh script
CHECK_DEPENDENCIES_SCRIPT="./check_docusaurus_dependencies.sh"

# Function to start Docusaurus server
start_docusaurus_server() {
    echo "Checking Dependencies - TuxTechIaaC Docusaurus"
    # Check dependencies before starting server
    if ! "$CHECK_DEPENDENCIES_SCRIPT"; then
        echo "Dependency check failed. Cannot start Docusaurus server."
        exit 1
    fi
    echo "Starting TuxTechIaaC Documentation Docusaurus server..."
    cd ../www/tuxtechiaac || exit
    npm start > /dev/null 2>&1 &
    echo "Starting Node Server in Background. Sleeping for 10 Seconds."
    sleep 10
    echo "TuxTechIaaC Documentation Docusaurus server is running on port 3000"
    pid=$(ps -ef | grep "docusaurus.mjs start" | grep -v grep | awk '{print $2}')
    echo "TuxTechIaaC Docusaurus Application PID: $pid"
}

# Function to stop Docusaurus server
stop_docusaurus_server() {
    echo "Stopping TuxTechIaaC Documentation Docusaurus server..."

    # Find PID of Docusaurus process
    pid=$(ps -ef | grep "docusaurus.mjs start" | grep -v grep | awk '{print $2}')

    if [ -n "$pid" ]; then
        # Kill the process using PID
        kill -SIGINT "$pid"
        echo "Stopped Docusaurus server with PID $pid"
    else
        echo "No running Docusaurus server found."
    fi
}

# Help function
show_help() {
    echo "Usage: $0 [--start|--stop|--help]"
    echo "Manage TuxTechIaaC Documentation Docusaurus server."
    echo
    echo "Options:"
    echo "  --start    Start the Docusaurus server"
    echo "  --stop     Stop the Docusaurus server"
    echo "  --help     Display this help message"
    exit 0
}

# Main function
main() {
    # Parse command-line arguments
    case "$1" in
        "--start")
            start_docusaurus_server
            ;;
        "--stop")
            stop_docusaurus_server
            ;;
        "--help")
            show_help
            ;;
        *)
            echo "Invalid option: $1"
            show_help
            ;;
    esac
}

# Call the main function with command-line argument
main "$@"
