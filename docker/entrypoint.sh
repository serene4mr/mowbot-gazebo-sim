#!/bin/bash

# Mowbot Gazebo Simulation Container Entrypoint
# This script runs when the container starts

set -e

echo "=== Mowbot Gazebo Simulation Container ==="
echo "Container started at: $(date)"
echo "Gazebo version: $(gz sim --version 2>/dev/null || echo 'Not available')"
echo ""

# Set environment variables
export GAZEBO_MODEL_PATH="/opt/gazebo/models:${GAZEBO_MODEL_PATH:-}"
export GAZEBO_RESOURCE_PATH="/opt/gazebo/worlds:${GAZEBO_RESOURCE_PATH:-}"
export GAZEBO_PLUGIN_PATH="/opt/gazebo/plugins:${GAZEBO_PLUGIN_PATH:-}"

echo "Environment variables set:"
echo "  GAZEBO_MODEL_PATH: $GAZEBO_MODEL_PATH"
echo "  GAZEBO_RESOURCE_PATH: $GAZEBO_RESOURCE_PATH"
echo "  GAZEBO_PLUGIN_PATH: $GAZEBO_PLUGIN_PATH"
echo ""

# Check if custom world is provided
if [ -n "$WORLD_FILE" ]; then
    echo "Using custom world: $WORLD_FILE"
    WORLD_PATH="$WORLD_FILE"
else
    # Default world
    WORLD_PATH="/opt/gazebo/worlds/lawn_world.sdf"
    echo "Using default world: $WORLD_PATH"
fi

# Check if world file exists
if [ ! -f "$WORLD_PATH" ]; then
    echo "Error: World file not found: $WORLD_PATH"
    echo "Available worlds:"
    ls -la /opt/gazebo/worlds/ || echo "No worlds directory found"
    exit 1
fi

echo ""
echo "Starting Gazebo simulation..."
echo "World: $WORLD_PATH"
echo ""

# Start Gazebo with the specified world
exec gz sim "$WORLD_PATH"
