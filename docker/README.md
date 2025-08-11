# Docker Configuration

This folder contains all Docker-related files for the Mowbot Gazebo Simulation environment.

## Files

- **Dockerfile** - Container image definition with Gazebo Harmonic
- **docker-compose.yml** - Multi-container orchestration
- **entrypoint.sh** - Container startup script with environment setup
- **build.sh** - Build utility with various options

## Quick Start

### Build the container
```bash
# From the root directory
./docker/build.sh

# Or with custom tag
./docker/build.sh -t v1.0
```

### Run with Docker
```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --network=host \
  mowbot-gazebo-sim:latest
```

### Run with Docker Compose
```bash
# From the root directory
docker-compose -f docker/docker-compose.yml up

# Or from this directory
docker-compose up
```

## Build Script Options

```bash
./build.sh -h                    # Show help
./build.sh -t v1.0              # Build with tag v1.0
./build.sh -n my-sim            # Build with custom name
./build.sh --no-cache           # Build without cache
./build.sh --push               # Push to registry after build
```

## Environment Variables

The container supports these environment variables:

- `WORLD_FILE` - Path to custom world file
- `GAZEBO_MODEL_PATH` - Additional model paths
- `GAZEBO_RESOURCE_PATH` - Additional resource paths
- `GAZEBO_PLUGIN_PATH` - Additional plugin paths

## Available Worlds

- `lawn_world` - Main lawn environment with obstacles
- `test_area` - Testing environment with simple obstacles
- `empty_world` - Clean environment with just ground plane

To use a specific world:
```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -e WORLD_FILE=/opt/gazebo/worlds/empty_world.sdf \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --network=host \
  mowbot-gazebo-sim:latest
```

## Integration with ROS 2

This container is designed to run alongside your ROS 2 application container:

```yaml
# In your main docker-compose.yml
services:
  gazebo-sim:
    image: mowbot-gazebo-sim:latest
    network_mode: host
    environment:
      - DISPLAY=${DISPLAY}
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
  
  ros2-app:
    image: your-ros2-app:latest
    network_mode: host
    depends_on:
      - gazebo-sim
```
