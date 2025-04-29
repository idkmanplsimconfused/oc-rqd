#!/bin/bash
# OpenCue RQD Client Setup Script for Linux
# Based on option 1 from https://www.opencue.io/docs/getting-started/deploying-rqd/

# Function to display help
show_help() {
    echo "Usage: ./start-rqd.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --cuebot-hostname HOSTNAME  The hostname or IP address of the Cuebot server"
    echo "  -n, --name NAME                 The name to give to the RQD container (default: rqd01)"
    echo "  -h, --help                      Display this help message"
    exit 0
}

# Parse command line arguments
CUEBOT_HOSTNAME=""
RQD_NAME="rqd01"

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--cuebot-hostname)
            CUEBOT_HOSTNAME="$2"
            shift 2
            ;;
        -n|--name)
            RQD_NAME="$2"
            shift 2
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

# Check if CUEBOT_HOSTNAME is set in environment or via parameter
if [ -z "$CUEBOT_HOSTNAME" ]; then
    if [ -z "$CUEBOT_HOSTNAME" ]; then
        echo "Error: Cuebot hostname not provided. Either:"
        echo "  1. Set the CUEBOT_HOSTNAME environment variable, or"
        echo "  2. Provide it as a parameter: ./start-rqd.sh -c <hostname or IP>"
        echo ""
        echo "Run ./start-rqd.sh --help for more information."
        exit 1
    fi
fi

# Set up the filesystem root for OpenCue
CUE_FS_ROOT="${HOME}/opencue-demo"
if [ ! -d "$CUE_FS_ROOT" ]; then
    echo "Creating OpenCue filesystem root directory at $CUE_FS_ROOT..."
    mkdir -p "$CUE_FS_ROOT"
fi

# Set environment variables
export CUEBOT_HOSTNAME="$CUEBOT_HOSTNAME"
export CUE_FS_ROOT="$CUE_FS_ROOT"

echo "RQD Configuration Summary:"
echo "=========================="
echo "Cuebot Hostname: $CUEBOT_HOSTNAME"
echo "RQD Container Name: $RQD_NAME"
echo "OpenCue Filesystem Root: $CUE_FS_ROOT"
echo ""

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    echo "Please install Docker and try again."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker is not running."
    echo "Please start the Docker service and try again."
    exit 1
fi

# Check if the RQD container already exists
if docker container inspect "$RQD_NAME" &> /dev/null; then
    echo "RQD container '$RQD_NAME' already exists."
    
    # Check if the container is running
    if docker ps -q -f "name=$RQD_NAME" &> /dev/null; then
        echo "RQD container is already running."
    else
        echo "Starting existing RQD container..."
        docker start "$RQD_NAME"
    fi
else
    # Pull the RQD image from DockerHub
    echo "Pulling RQD image from DockerHub..."
    docker pull opencue/rqd
    
    # Run the RQD container
    echo "Starting RQD container..."
    docker run -td --name "$RQD_NAME" --env CUEBOT_HOSTNAME="$CUEBOT_HOSTNAME" --volume "${CUE_FS_ROOT}:${CUE_FS_ROOT}" opencue/rqd
fi

# Verify the container is running
if docker ps -q -f "name=$RQD_NAME" &> /dev/null; then
    echo "RQD container is now running."
    
    # Display the logs
    echo "RQD container logs:"
    echo "=================="
    docker logs "$RQD_NAME" --tail 20
else
    echo "Error: Failed to start RQD container."
    echo "Check Docker logs for more information:"
    echo "docker logs $RQD_NAME"
    exit 1
fi

echo ""
echo "RQD setup complete!"
echo "To stop RQD, run: docker stop $RQD_NAME"
echo "To view RQD logs, run: docker logs $RQD_NAME" 