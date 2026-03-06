# Use ROS 2 Humble base image on Ubuntu 22.04 (Jammy)
FROM ros:humble-ros-base-jammy

# Apply security updates from base image
RUN apt-get update && apt-get upgrade -y --no-install-recommends && rm -rf /var/lib/apt/lists/*

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
    # Plugin development dependencies (optional - add if you plan to build plugins)
    # libgz-sim8-dev rapidjson-dev \
    && rm -rf /var/lib/apt/lists/*

# Add Gazebo Fortress repository and install it
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/gazebo-stable.list && \
    apt-get update && apt-get install -y ignition-fortress && \
    rm -rf /var/lib/apt/lists/*

