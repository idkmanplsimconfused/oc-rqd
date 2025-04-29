#!/bin/bash
# OpenCue RQD Client Stop Script for Linux

# Function to display help
show_help() {
    echo "Usage: ./stop-rqd.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME    The name of the RQD container to stop (default: rqd01)"
    echo "  -r, --remove       Also remove the container after stopping"
    echo "  -h, --help         Display this help message"
    exit 0
}

# Parse command line arguments
RQD_NAME="rqd01"
REMOVE=false

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--name)
            RQD_NAME="$2"
            shift 2
            ;;
        -r|--remove)
            REMOVE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Error: Unknown option $1"
            show_help
            ;;
    esac
done

# Check if the RQD container exists
if ! docker container inspect "$RQD_NAME" &> /dev/null; then
    echo "RQD container '$RQD_NAME' does not exist."
    exit 0
fi

# Check if the container is running
if docker ps -q -f "name=$RQD_NAME" &> /dev/null; then
    echo "Stopping RQD container '$RQD_NAME'..."
    docker stop "$RQD_NAME"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to stop RQD container."
        exit 1
    fi
    
    echo "RQD container stopped successfully."
else
    echo "RQD container '$RQD_NAME' is not running."
fi

# Remove the container if requested
if [ "$REMOVE" = true ]; then
    echo "Removing RQD container '$RQD_NAME'..."
    docker rm "$RQD_NAME"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to remove RQD container."
        exit 1
    fi
    
    echo "RQD container removed successfully."
fi 