#!/bin/bash
set -e

# Function to add path if directory exists and has content
add_resource_path() {
    if [ -d "$1" ] && [ "$(ls -A $1 2>/dev/null)" ]; then
        if [ -z "$GZ_SIM_RESOURCE_PATH" ]; then
            export GZ_SIM_RESOURCE_PATH="$1"
        else
            export GZ_SIM_RESOURCE_PATH="$1:$GZ_SIM_RESOURCE_PATH"
        fi
        echo "Added to GZ_SIM_RESOURCE_PATH: $1"
    fi
}

echo "=== Gazebo Harmonic Container Setup ==="

# Source ROS 2 environment
source /opt/ros/humble/setup.bash
echo "✓ ROS 2 Humble sourced"

# Initialize GZ_SIM_RESOURCE_PATH
export GZ_SIM_RESOURCE_PATH=""

# Add container resources (your custom resources)
echo "Adding container resources..."
add_resource_path "/opt/gazebo/models"
add_resource_path "/opt/gazebo/worlds" 
add_resource_path "/opt/gazebo/assets"
add_resource_path "/opt/gazebo/meshes"

# Add workspace resources (for dev container bind mounts)
echo "Checking for workspace resources..."
add_resource_path "/workspace/gazebo_resources/models"
add_resource_path "/workspace/gazebo_resources/worlds"
add_resource_path "/workspace/gazebo_resources/assets"
add_resource_path "/workspace/gazebo_resources/meshses"  # Note: matches your dir name

# Set legacy environment variables for compatibility
export GAZEBO_MODEL_PATH="$GZ_SIM_RESOURCE_PATH"
export GAZEBO_RESOURCE_PATH="$GZ_SIM_RESOURCE_PATH"
export GAZEBO_PLUGIN_PATH="/opt/gazebo/plugins"

# Display configuration
echo "=== Environment Configuration ==="
echo "GZ_SIM_RESOURCE_PATH: $GZ_SIM_RESOURCE_PATH"
echo "GAZEBO_MODEL_PATH: $GAZEBO_MODEL_PATH"
echo "GAZEBO_RESOURCE_PATH: $GAZEBO_RESOURCE_PATH"

# List available worlds for verification
echo "=== Available Worlds ==="
find /opt/gazebo/worlds -name "*.sdf" -o -name "*.world" 2>/dev/null || echo "No world files found"

echo "=== Starting Gazebo ==="
exec "$@"
