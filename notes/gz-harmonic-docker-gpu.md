# Gazebo Harmonic Docker with ROS 2 and GPU Support

## Prerequisites

### Host System Requirements

#### NVIDIA Container Toolkit Installation
```bash
# Add NVIDIA repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install NVIDIA Container Toolkit
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

#### WSL2 GPU Driver (Windows users)
- Install NVIDIA WSL2 GPU driver from NVIDIA website
- Use Windows host driver, not Linux driver in WSL2

## Docker Configuration

### Improved Dockerfile
```dockerfile
FROM ros:humble-ros-base-jammy

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV GAZEBO_MODEL_PATH=/opt/gazebo/models
ENV GAZEBO_RESOURCE_PATH=/opt/gazebo/worlds
ENV GAZEBO_PLUGIN_PATH=/opt/gazebo/plugins

# GPU and GUI support
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
ENV LIBGL_ALWAYS_INDIRECT=0
ENV MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA

# Install system dependencies and graphics libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl wget lsb-release software-properties-common \
    # Essential graphics libraries for OGRE2
    libgl1-mesa-glx libgl1-mesa-dri \
    libglvnd0 libgl1 libglx0 libegl1 libgles2 \
    mesa-utils mesa-utils-extra \
    # X11 and Wayland support
    libx11-6 libxcb1 libxau6 libxdmcp6 \
    libxext6 libxrender1 libxtst6 \
    libwayland-client0 libwayland-cursor0 \
    # Development tools
    build-essential cmake git python3-pip python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Add Gazebo Harmonic repository
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/gazebo-stable.list && \
    apt-get update && apt-get install -y gz-harmonic && \
    rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /opt/gazebo/{worlds,models,plugins,assets}

WORKDIR /opt/gazebo
EXPOSE 11345
```

### Docker Run Command
```bash
# Allow X11 forwarding
xhost +local:docker

# Run container with GPU and GUI support
docker run -it --rm \
    --gpus all \
    --device=/dev/dri:/dev/dri \
    --device=/dev/dxg \
    --group-add video \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /mnt/wslg:/mnt/wslg \
    -v /usr/lib/wsl:/usr/lib/wsl \
    -e DISPLAY=$DISPLAY \
    -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -e LD_LIBRARY_PATH=/usr/lib/wsl/lib \
    --privileged \
    --name gazebo-harmonic \
    your-image-name
```

## VS Code Dev Container Configuration

### devcontainer.json
```json
{
  "name": "Mowbot Gazebo Simulation",
  "image": "ghcr.io/serene4mr/mowbot-gazebo-sim:latest",
  "hostRequirements": {
    "gpu": "optional"
  },
  "runArgs": [
    "--network=host",
    "--ipc=host",
    "--privileged",
    "--device=/dev/dxg",
    "--volume=/usr/lib/wsl:/usr/lib/wsl",
    "--volume=/tmp/.X11-unix:/tmp/.X11-unix:rw",
    "--volume=/mnt/wslg:/mnt/wslg",
    "--volume=/dev:/dev"
  ],
  "remoteEnv": {
    "DISPLAY": "${localEnv:DISPLAY}",
    "WAYLAND_DISPLAY": "${localEnv:WAYLAND_DISPLAY}",
    "XDG_RUNTIME_DIR": "${localEnv:XDG_RUNTIME_DIR}",
    "NVIDIA_VISIBLE_DEVICES": "all",
    "NVIDIA_DRIVER_CAPABILITIES": "all",
    "QT_X11_NO_MITSHM": "1",
    "LIBGL_ALWAYS_INDIRECT": "0",
    "MESA_D3D12_DEFAULT_ADAPTER_NAME": "NVIDIA"
  },
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached",
  "workspaceFolder": "/workspace"
}
```

## Testing and Troubleshooting

### Verify GPU Access
```bash
# Check NVIDIA GPU
nvidia-smi

# Check OpenGL rendering
glxinfo | grep "OpenGL renderer"

# Test X11 forwarding
echo $DISPLAY
xeyes
```

### Common Issues and Solutions

#### GPU Not Working
```bash
# Force software rendering fallback
export LIBGL_ALWAYS_SOFTWARE=1
gz sim your_world.sdf
```

#### Switch Rendering Engine
```bash
# Use OGRE1 instead of OGRE2
export GZ_SIM_RENDER_ENGINE=ogre
gz sim your_world.sdf
```

#### Headless Mode
```bash
# For server/CI environments
gz sim --headless your_world.sdf
```

### Performance Optimization
```bash
# Check real-time factor
gz topic -e -t /stats

# Monitor GPU usage
nvidia-smi -l 1
```

## Quick Start Commands

### Build and Run
```bash
# Build image
docker build -t gazebo-harmonic-gpu .

# Run with GUI
docker run -it --rm --gpus all \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    gazebo-harmonic-gpu

# Inside container
gz sim
```

### ROS 2 Integration
```bash
# Source ROS 2
source /opt/ros/humble/setup.bash

# Run Gazebo with ROS 2 bridge
ros2 launch ros_gz_sim gz_sim.launch.py gz_args:="your_world.sdf"
```

## Important Notes

- **WSL2 Users**: Use `/dev/dxg` device and WSL library mounts
- **X11 Forwarding**: Essential for GUI applications
- **GPU Drivers**: Must match between host and container
- **OpenGL Version**: Gazebo Harmonic requires OpenGL 3.3+
- **OGRE2**: Default rendering engine, fallback to OGRE1 if issues
- **Privileged Mode**: Required for full GPU and device access