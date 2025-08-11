#!/bin/bash

# Development entrypoint for VS Code Dev Container

set -e

echo "🚀 Setting up Mowbot Gazebo Simulation Development Environment..."

# Set up environment variables
export GAZEBO_MODEL_PATH="/opt/gazebo/models:/opt/gazebo/gazebo_resources/models"
export GAZEBO_RESOURCE_PATH="/opt/gazebo/worlds:/opt/gazebo/gazebo_resources/worlds"
export GAZEBO_PLUGIN_PATH="/opt/gazebo/plugins:/opt/gazebo/gazebo_resources/plugins"
export GAZEBO_MATERIAL_PATH="/opt/gazebo/materials:/opt/gazebo/gazebo_resources/materials"

# Check if we're in a development environment
if [ -n "$VSCODE_EXTENSION_DEVELOPMENT_PATH" ]; then
    echo "📝 VS Code Dev Container detected"
fi

# Verify Gazebo installation
if command -v gz &> /dev/null; then
    echo "✅ Gazebo Harmonic installed: $(gz --version)"
else
    echo "❌ Gazebo Harmonic not found"
    exit 1
fi

# Check available worlds
echo "🌍 Available worlds:"
if [ -d "/opt/gazebo/gazebo_resources/worlds" ]; then
    ls -la /opt/gazebo/gazebo_resources/worlds/
else
    echo "No worlds found in gazebo_resources/worlds/"
fi

# Check available models
echo "🏗️ Available models:"
if [ -d "/opt/gazebo/gazebo_resources/models" ]; then
    ls -la /opt/gazebo/gazebo_resources/models/
else
    echo "No models found in gazebo_resources/models/"
fi

echo "🎯 Development environment ready!"
echo ""
echo "Quick commands:"
echo "  gz sim /opt/gazebo/gazebo_resources/worlds/test_world.sdf  # Run test world"
echo "  gz model --list                                            # List available models"
echo "  gz model --download <model_name>                          # Download model"
echo ""

# If arguments are provided, execute them
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Default to bash
    exec /bin/bash
fi
