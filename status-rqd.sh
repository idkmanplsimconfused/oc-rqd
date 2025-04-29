#!/bin/bash
# OpenCue RQD Client Status Script for Linux

# Function to display help
show_help() {
    echo "Usage: ./status-rqd.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME    The name of the RQD container to check (default: rqd01)"
    echo "  -l, --logs         Show container logs"
    echo "  -t, --tail LINES   Number of log lines to display (default: 25, used with --logs)"
    echo "  -h, --help         Display this help message"
    exit 0
}

# Parse command line arguments
RQD_NAME="rqd01"
SHOW_LOGS=false
LOG_LINES=25

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--name)
            RQD_NAME="$2"
            shift 2
            ;;
        -l|--logs)
            SHOW_LOGS=true
            shift
            ;;
        -t|--tail)
            LOG_LINES="$2"
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

# Check if the RQD container exists
if ! docker container inspect "$RQD_NAME" &> /dev/null; then
    echo "RQD container '$RQD_NAME' does not exist."
    exit 1
fi

# Check if the container is running
if docker ps -q -f "name=$RQD_NAME" &> /dev/null; then
    echo "RQD container '$RQD_NAME' is RUNNING"
    
    # Show container details
    echo ""
    echo "Container Details:"
    echo "=================="
    
    # Get container IP
    CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$RQD_NAME")
    echo "Container IP: $CONTAINER_IP"
    
    # Get container creation time
    CREATION_TIME=$(docker inspect -f '{{.Created}}' "$RQD_NAME")
    echo "Created: $CREATION_TIME"
    
    # Get container network
    NETWORK=$(docker inspect -f '{{range $key, $value := .NetworkSettings.Networks}}{{$key}}{{end}}' "$RQD_NAME")
    echo "Network: $NETWORK"
    
    # Show port mappings if any
    PORTS=$(docker inspect -f '{{range $port, $_ := .NetworkSettings.Ports}}{{$port}} {{end}}' "$RQD_NAME")
    if [ -n "$PORTS" ]; then
        echo "Exposed Ports: $PORTS"
    else
        echo "Exposed Ports: None"
    fi
else
    echo "RQD container '$RQD_NAME' is NOT RUNNING"
fi

# Show logs if requested
if [ "$SHOW_LOGS" = true ]; then
    echo ""
    echo "Container Logs (last $LOG_LINES lines):"
    echo "=================================="
    docker logs "$RQD_NAME" --tail "$LOG_LINES"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve container logs."
        exit 1
    fi
fi 