#!/bin/bash

# Mowbot Gazebo Simulation Build Script
# Usage: ./build.sh [options]

set -e

# Default values
IMAGE_NAME="mowbot-gazebo-sim"
TAG="latest"
BUILD_CONTEXT="."
DOCKERFILE="docker/Dockerfile"
NO_CACHE=false
PUSH=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
    echo "Mowbot Gazebo Simulation Build Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -t, --tag TAG       Set image tag (default: latest)"
    echo "  -n, --name NAME     Set image name (default: mowbot-gazebo-sim)"
    echo "  --no-cache          Build without using cache"
    echo "  --push              Push image to registry after build"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build with default settings"
    echo "  $0 -t v1.0           # Build with tag v1.0"
    echo "  $0 --no-cache        # Build without cache"
    echo "  $0 -n my-sim -t dev  # Build with custom name and tag"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --push)
            PUSH=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Build arguments
BUILD_ARGS=""
if [ "$NO_CACHE" = true ]; then
    BUILD_ARGS="$BUILD_ARGS --no-cache"
fi

FULL_IMAGE_NAME="$IMAGE_NAME:$TAG"

print_info "Building Gazebo simulation container..."
print_info "Image: $FULL_IMAGE_NAME"
print_info "Context: $BUILD_CONTEXT"
print_info "Dockerfile: $DOCKERFILE"

# Build the image
docker build $BUILD_ARGS \
    -f "$DOCKERFILE" \
    -t "$FULL_IMAGE_NAME" \
    "$BUILD_CONTEXT"

if [ $? -eq 0 ]; then
    print_info "Build completed successfully!"
    
    if [ "$PUSH" = true ]; then
        print_info "Pushing image to registry..."
        docker push "$FULL_IMAGE_NAME"
    fi
    
    print_info "You can now run the container with:"
    echo "  docker run -it --rm \\"
    echo "    -e DISPLAY=\$DISPLAY \\"
    echo "    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \\"
    echo "    --network=host \\"
    echo "    $FULL_IMAGE_NAME"
else
    print_error "Build failed!"
    exit 1
fi
