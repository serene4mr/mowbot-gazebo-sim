# Mowbot Gazebo Simulation Environment

A dedicated repository for launching and managing Gazebo simulation worlds/environments for the Mowbot project, decoupled from robot code.

## Purpose

This repository contains only the Gazebo simulation environment and serves as a modular simulation backend that your main ROS 2 repository can connect to. It's designed to run inside its own Docker container, separate from your ROS 2 application container.

## Architecture

- **Gazebo Container** (from this repo) → runs the simulation world
- **ROS 2 Container** (from your main mowbot repo) → spawns the robot into the world, runs ROS 2 nodes, and consumes sensor data
- Both containers communicate over `--network=host` with `ros_gz_bridge` bridging topics/services

## Repository Structure

```
mowbot-gazebo-sim/
├── docker/                      # Docker configuration and scripts
│   ├── Dockerfile              # Gazebo Harmonic container setup
│   ├── docker-compose.yml      # Container orchestration
│   ├── entrypoint.sh           # Container startup script
│   └── build.sh                # Build utility script
├── gazebo_resources/           # All Gazebo simulation assets
│   ├── worlds/                 # Simulation world files
│   │   ├── test_world.sdf      # Test environment
│   │   ├── baylands.world      # Baylands environment
│   │   └── empty_world.sdf     # Empty world for testing
│   ├── models/                 # Environmental assets (non-robot)
│   ├── plugins/                # Custom Gazebo plugins
│   ├── materials/              # Material definitions
│   ├── textures/               # Texture files
│   └── meshes/                 # 3D mesh files
├── scripts/                     # Launch and utility scripts
│   └── start_gazebo.sh
├── assets/                      # Additional simulation assets
├── .devcontainer/               # VS Code Dev Container configuration
│   ├── devcontainer.json       # Dev container settings
│   ├── Dockerfile              # Development environment
│   ├── docker-compose.yml      # Dev container orchestration
│   └── README.md               # Development guide
└── README.md                    # This file

## Quick Start

### Using VS Code Dev Container (Recommended for Development)

1. **Open in VS Code** with the Remote - Containers extension
2. **Click "Reopen in Container"** when prompted
3. **Start developing!** All tools and environment are pre-configured

See `.devcontainer/README.md` for detailed development workflow.

### Using Docker

1. **Build the container:**
   ```bash
   # Using the build script (recommended)
   ./docker/build.sh
   
   # Or manually
   docker build -f docker/Dockerfile -t ghcr.io/serene4mr/mowbot-gazebo-sim:latest .
   ```

2. **Run the simulation:**
   ```bash
   docker run -it --rm \
     -e DISPLAY=$DISPLAY \
     -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
     --network=host \
     ghcr.io/serene4mr/mowbot-gazebo-sim:latest
   ```

### Using Docker Compose

```bash
# From the root directory
docker-compose -f docker/docker-compose.yml up

# Or from the docker directory
cd docker && docker-compose up
```

## Integration with ROS 2

In your main mowbot ROS 2 repository, you can spawn robots into this running world using:

```bash
# Spawn a robot entity
gz service -s /world/lawn_world/create \
  --reqtype gz.msgs.EntityFactory \
  --reptype gz.msgs.Boolean \
  -r 'sdf_filename: "path/to/robot.sdf"'
```

## Development

### Adding New Worlds

1. Create your `.sdf` or `.world` file in the `gazebo_resources/worlds/` directory
2. Update the launch scripts to include your new world
3. Test with: `./scripts/start_gazebo.sh gazebo_resources/worlds/your_new_world.sdf`

### Adding Environmental Models

1. Place model files in the `gazebo_resources/models/` directory
2. Ensure models follow Gazebo's model structure
3. Reference them in your world files

### Custom Plugins

1. Develop plugins in the `gazebo_resources/plugins/` directory
2. Build and install them in the Dockerfile
3. Reference them in your world files

## What This Repository Contains

✅ **Worlds** (.sdf/.world) describing environments  
✅ **Environmental models/assets** (grass, fences, trees, buildings)  
✅ **Generic Gazebo plugins** for simulation physics or environment sensors  
✅ **Simulation launch scripts**  
✅ **Docker configuration** for Gazebo Sim Harmonic  
✅ **Container orchestration** with Docker Compose  
✅ **Build utilities** for easy container management  

## What This Repository Does NOT Contain

❌ Robot-specific models, URDF/XACRO, meshes, robot controllers  
❌ ROS 2 application code, navigation stacks, or perception nodes  
❌ Robot-specific ros_gz_bridge configs (those stay in your main ROS 2 repo)  

## Docker Organization

The `docker/` folder contains all container-related files:

- **Dockerfile** - Container image definition with Gazebo Harmonic
- **docker-compose.yml** - Multi-container orchestration
- **entrypoint.sh** - Container startup and environment setup
- **build.sh** - Build utility with options for different configurations

This organization allows for:
- Easy addition of development/production variants
- Clear separation of container logic from simulation assets
- Simplified CI/CD integration
- Better maintainability as the project grows

## Requirements

- Docker
- X11 forwarding support (for GUI)
- Network access for container communication

## License

[Add your license information here]
