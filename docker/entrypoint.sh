#!/bin/bash
set -e

# Function to add resource path
add_resource_path() {
    if [ -d "$1" ] && [ "$(ls -A "$1" 2>/dev/null)" ]; then
        if [ -z "$GZ_SIM_RESOURCE_PATH" ]; then
            export GZ_SIM_RESOURCE_PATH="$1"
        else
            export GZ_SIM_RESOURCE_PATH="$1:$GZ_SIM_RESOURCE_PATH"
        fi
        echo "Added to GZ_SIM_RESOURCE_PATH: $1"
    fi
}

# Function to add plugin path
add_plugin_path() {
    if [ -d "$1" ] && [ "$(ls -A "$1" 2>/dev/null)" ]; then
        if [ -z "$GZ_SIM_SYSTEM_PLUGIN_PATH" ]; then
            export GZ_SIM_SYSTEM_PLUGIN_PATH="$1"
        else
            export GZ_SIM_SYSTEM_PLUGIN_PATH="$1:$GZ_SIM_SYSTEM_PLUGIN_PATH"
        fi
        echo "Added to GZ_SIM_SYSTEM_PLUGIN_PATH: $1"
    fi
}

echo "=== Gazebo Harmonic Container Setup ==="

# Source ROS 2 environment for this shell
source /opt/ros/humble/setup.bash
echo "✓ ROS 2 Humble sourced for entrypoint shell"

# Ensure ROS 2 is sourced for ALL future terminals
# if ! grep -q "source /opt/ros/humble/setup.bash" ~/.bashrc 2>/dev/null; then
#     echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
#     echo "✓ Added ROS 2 sourcing to ~/.bashrc"
# fi

# Initialize paths
export GZ_SIM_RESOURCE_PATH=""
export GZ_SIM_SYSTEM_PLUGIN_PATH=""

# Add container resources
add_resource_path "/opt/gazebo/models"
add_resource_path "/opt/gazebo/worlds"
add_resource_path "/opt/gazebo/assets"
add_resource_path "/opt/gazebo/meshes"

# Add workspace resources (devcontainer bind mounts)
add_resource_path "/workspace/gazebo_resources/models"
add_resource_path "/workspace/gazebo_resources/worlds"
add_resource_path "/workspace/gazebo_resources/assets"
add_resource_path "/workspace/gazebo_resources/meshses"

# Add plugin paths
add_plugin_path "/opt/gazebo/plugins"
add_plugin_path "/workspace/gazebo_resources/plugins"

# Legacy Gazebo env vars for compatibility
export GAZEBO_MODEL_PATH="$GZ_SIM_RESOURCE_PATH"
export GAZEBO_RESOURCE_PATH="$GZ_SIM_RESOURCE_PATH"
export GAZEBO_PLUGIN_PATH="$GZ_SIM_SYSTEM_PLUGIN_PATH"

# Show final env configuration
echo "GZ_SIM_RESOURCE_PATH: $GZ_SIM_RESOURCE_PATH"
echo "GZ_SIM_SYSTEM_PLUGIN_PATH: $GZ_SIM_SYSTEM_PLUGIN_PATH"

echo "=== Starting Gazebo ==="
exec "$@"
