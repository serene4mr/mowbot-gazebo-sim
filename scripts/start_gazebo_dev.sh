#!/bin/bash

# Mowbot Gazebo Simulation - Dev Container Version
# This script runs inside the dev container (no Docker needed)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "Mowbot Gazebo Simulation - Dev Container Version"
    echo ""
    echo "Usage: $0 [world_file]"
    echo ""
    echo "Arguments:"
    echo "  world_file    Path to .sdf or .world file (optional)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Start with default world"
    echo "  $0 /opt/gazebo/worlds/test_world.sdf  # Start with built-in world"
    echo "  $0 /workspace/gazebo_resources/worlds/test_world.sdf  # Start with workspace world"
    echo "  $0 -h                                 # Show this help"
    echo ""
    echo "Available worlds:"
    echo "  Built-in:"
    ls -1 /opt/gazebo/worlds/*.{sdf,world} 2>/dev/null | sed 's/^/    /' || echo "    No built-in worlds found"
    echo "  Workspace:"
    ls -1 /workspace/gazebo_resources/worlds/*.{sdf,world} 2>/dev/null | sed 's/^/    /' || echo "    No workspace worlds found"
}

# Function to check if file exists
check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        print_error "World file not found: $file"
        return 1
    fi
    return 0
}

# Function to get file type
get_file_type() {
    local file="$1"
    local extension="${file##*.}"
    case "$extension" in
        sdf) echo "sdf" ;;
        world) echo "world" ;;
        *) echo "unknown" ;;
    esac
}

# Function to check Gazebo installation
check_gazebo() {
    if ! command -v gz &> /dev/null; then
        print_error "Gazebo not found. Please check your installation."
        exit 1
    fi
    print_info "Gazebo found: $(gz --version)"
}

# Function to check GUI support
check_gui() {
    if [ -n "$DISPLAY" ]; then
        print_info "GUI support available (DISPLAY: $DISPLAY)"
        if xset q &>/dev/null; then
            print_info "X11 connection working"
        else
            print_warning "X11 connection failed - GUI may not work"
        fi
    else
        print_warning "No GUI support (DISPLAY not set) - running in headless mode"
    fi
}

# Function to set environment variables
set_environment() {
    export GAZEBO_MODEL_PATH="/root/.gz/fuel/fuel.gazebosim.org/openrobotics/models:/opt/gazebo/models:/workspace/gazebo_resources/models"
    export GAZEBO_RESOURCE_PATH="/opt/gazebo/worlds:/workspace/gazebo_resources/worlds"
    export GAZEBO_PLUGIN_PATH="/opt/gazebo/plugins:/workspace/gazebo_resources/plugins"
    export GAZEBO_MATERIAL_PATH="/opt/gazebo/materials:/workspace/gazebo_resources/materials"
    
    print_info "Environment variables set:"
    echo "  GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH"
    echo "  GAZEBO_RESOURCE_PATH=$GAZEBO_RESOURCE_PATH"
    echo "  GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH"
    echo "  GAZEBO_MATERIAL_PATH=$GAZEBO_MATERIAL_PATH"
}

# Function to start Gazebo
start_gazebo() {
    local world_file="$1"
    local file_type=$(get_file_type "$world_file")
    
    print_info "Starting Gazebo simulation with world file: $world_file"
    print_info "File type: $file_type"
    
    echo ""
    print_info "Launching Gazebo..."
    
    # Start Gazebo
    gz sim "$world_file"
}

# Main execution
main() {
    # Parse arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        "")
            # Default world - try workspace first, then built-in
            if [ -f "/workspace/gazebo_resources/worlds/test_world.sdf" ]; then
                DEFAULT_WORLD="/workspace/gazebo_resources/worlds/test_world.sdf"
            elif [ -f "/opt/gazebo/worlds/test_world.sdf" ]; then
                DEFAULT_WORLD="/opt/gazebo/worlds/test_world.sdf"
            else
                print_error "No default world found. Please specify a world file."
                show_help
                exit 1
            fi
            WORLD_FILE="$DEFAULT_WORLD"
            ;;
        *)
            WORLD_FILE="$1"
            ;;
    esac
    
    # Validate world file
    if ! check_file "$WORLD_FILE"; then
        show_help
        exit 1
    fi
    
    # Check prerequisites
    check_gazebo
    check_gui
    set_environment
    
    # Start Gazebo
    start_gazebo "$WORLD_FILE"
}

# Run main function
main "$@"
