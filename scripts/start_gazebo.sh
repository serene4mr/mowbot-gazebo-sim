#!/bin/bash

# Mowbot Gazebo Simulation Startup Script
# Usage: ./start_gazebo.sh [world_file.sdf]

set -e

# Default world
DEFAULT_WORLD="worlds/test_world.sdf"
WORLD_FILE=${1:-$DEFAULT_WORLD}

# Docker image name
DOCKER_IMAGE="ghcr.io/serene4mr/mowbot-gazebo-sim:latest"

# Function to check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker daemon is not running or you don't have permissions"
        exit 1
    fi
}

# Function to check if Docker image exists
check_image() {
    if ! docker images | grep -q "ghcr.io/serene4mr/mowbot-gazebo-sim.*latest"; then
        echo "Error: Docker image '$DOCKER_IMAGE' not found"
        echo "Please build the image first: ./docker/build.sh"
        exit 1
    fi
}

# Function to resolve file path
resolve_file_path() {
    local input_file="$1"
    
    # If it's an absolute path, use as is
    if [[ "$input_file" == /* ]]; then
        echo "$input_file"
    else
        # If it's a relative path, make it absolute from current directory
        echo "$(pwd)/$input_file"
    fi
}

# Help message
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Mowbot Gazebo Simulation Startup Script"
    echo ""
    echo "Usage: $0 [world_file.sdf]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Start with default world"
    echo "  $0 worlds/empty_world.sdf             # Start with local .sdf file"
    echo "  $0 /path/to/custom/world.sdf          # Start with absolute path"
    echo "  $0 -h                                 # Show this help message"
    echo ""
    echo "Note: This script automatically runs inside Docker container."
    echo "Make sure to build the image first: ./docker/build.sh"
    exit 0
fi

# Check Docker and image
check_docker
check_image

# Resolve the world file path
RESOLVED_FILE=$(resolve_file_path "$WORLD_FILE")

# Check if the world file exists
if [ ! -f "$RESOLVED_FILE" ]; then
    echo "Error: World file not found: $RESOLVED_FILE"
    echo ""
    echo "Usage: $0 [world_file.sdf]"
    echo "Example: $0 worlds/empty_world.sdf"
    exit 1
fi

# Get file extension
FILE_EXT="${RESOLVED_FILE##*.}"

# Validate file extension
if [ "$FILE_EXT" != "sdf" ] && [ "$FILE_EXT" != "world" ]; then
    echo "Error: Invalid file extension. Expected .sdf or .world, got .$FILE_EXT"
    echo "File: $RESOLVED_FILE"
    exit 1
fi

echo "Starting Gazebo simulation with world file: $RESOLVED_FILE"
echo "File type: $FILE_EXT"
echo "Running inside Docker container..."
echo ""

# Determine if we need to mount the file
if [[ "$RESOLVED_FILE" == /opt/gazebo/worlds/* ]]; then
    # File is already in the container, no need to mount
    CONTAINER_PATH="$RESOLVED_FILE"
    MOUNT_OPTION=""
else
    # File is outside container, need to mount it
    CONTAINER_PATH="/tmp/$(basename "$RESOLVED_FILE")"
    MOUNT_OPTION="-v $RESOLVED_FILE:$CONTAINER_PATH"
fi

# Set environment variables
export GAZEBO_MODEL_PATH="/opt/gazebo/models:${GAZEBO_MODEL_PATH:-}"
export GAZEBO_RESOURCE_PATH="/opt/gazebo/worlds:${GAZEBO_RESOURCE_PATH:-}"
export GAZEBO_PLUGIN_PATH="/opt/gazebo/plugins:${GAZEBO_PLUGIN_PATH:-}"

# Start Gazebo in Docker container
echo "Launching Gazebo..."
docker run -it --rm \
    -e DISPLAY="$DISPLAY" \
    -e GAZEBO_MODEL_PATH="$GAZEBO_MODEL_PATH" \
    -e GAZEBO_RESOURCE_PATH="$GAZEBO_RESOURCE_PATH" \
    -e GAZEBO_PLUGIN_PATH="$GAZEBO_PLUGIN_PATH" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    $MOUNT_OPTION \
    --network=host \
    --entrypoint="" \
    "$DOCKER_IMAGE" \
    bash -c "echo 'Environment variables set:' && env | grep GAZEBO && echo '' && echo 'Starting Gazebo with: $CONTAINER_PATH' && gz sim '$CONTAINER_PATH'"
