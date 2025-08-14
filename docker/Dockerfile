# Use ROS 2 Humble base image on Ubuntu 22.04 (Jammy)
FROM ros:humble-ros-base-jammy

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Essential for GPU and GUI support
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

# Install system dependencies and graphics libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl wget lsb-release software-properties-common \
    # Essential graphics libraries for OGRE2
    libgl1-mesa-glx libgl1-mesa-dri \
    libglvnd0 libgl1 libglx0 libegl1 libgles2 \
    mesa-utils mesa-utils-extra \
    # X11 and GUI support
    libx11-6 libxcb1 libxau6 libxdmcp6 \
    libxext6 libxrender1 libxtst6 \
    # Additional development tools
    build-essential cmake git python3-pip python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Add Gazebo Harmonic repository and install it
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/gazebo-stable.list && \
    apt-get update && apt-get install -y gz-harmonic && \
    rm -rf /var/lib/apt/lists/*

# Create directories for simulation assets
RUN mkdir -p /opt/gazebo/{worlds,models,plugins,assets,meshes}

# Copy your custom Gazebo resources from gazebo_resources directory
COPY gazebo_resources/models/ /opt/gazebo/models/
COPY gazebo_resources/worlds/ /opt/gazebo/worlds/
COPY gazebo_resources/assets/ /opt/gazebo/assets/
COPY gazebo_resources/meshses/ /opt/gazebo/meshes/

# Copy entrypoint script and utility scripts
COPY docker/entrypoint.sh /opt/gazebo/entrypoint.sh
COPY scripts/ /opt/gazebo/scripts/

# Make scripts executable
RUN chmod +x /opt/gazebo/scripts/*.sh && chmod +x /opt/gazebo/entrypoint.sh

# Set working directory
WORKDIR /opt/gazebo

# Expose Gazebo's communication port
EXPOSE 11345

# Set entrypoint
ENTRYPOINT ["/opt/gazebo/entrypoint.sh"]
CMD ["gz", "sim"]
