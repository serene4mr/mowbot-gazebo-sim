FROM ghcr.io/serene4mr/mowbot-gazebo-sim:latest

# Install additional development tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    nano \
    vim \
    htop \
    tree \
    build-essential \
    cmake \
    pkg-config \
    python3-pip \
    python3-dev \
    x11-apps \
    x11-utils \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Install Python development packages
RUN pip3 install --no-cache-dir \
    numpy \
    matplotlib \
    jupyter \
    ipython

# Install additional Gazebo development tools
RUN apt-get update && apt-get install -y \
    gz-harmonic-dev \
    libgz-cmake3-dev \
    libgz-common5-dev \
    libgz-math7-dev \
    libgz-msgs10-dev \
    libgz-transport14-dev \
    libgz-utils2-dev \
    && rm -rf /var/lib/apt/lists/*

# Create development workspace
WORKDIR /workspace

# Set up development environment
ENV DISPLAY="${DISPLAY:-:0}"
ENV GAZEBO_MODEL_PATH="/opt/gazebo/models:/opt/gazebo/gazebo_resources/models"
ENV GAZEBO_RESOURCE_PATH="/opt/gazebo/worlds:/opt/gazebo/gazebo_resources/worlds"
ENV GAZEBO_PLUGIN_PATH="/opt/gazebo/plugins:/opt/gazebo/gazebo_resources/plugins"
ENV GAZEBO_MATERIAL_PATH="/opt/gazebo/materials:/opt/gazebo/gazebo_resources/materials"

# Create a development entrypoint
COPY dev-entrypoint.sh /usr/local/bin/dev-entrypoint.sh
RUN chmod +x /usr/local/bin/dev-entrypoint.sh

# Default to bash for development
CMD ["/bin/bash"]
