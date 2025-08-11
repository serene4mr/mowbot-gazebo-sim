FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV GAZEBO_MODEL_PATH=/opt/gazebo/models
ENV GAZEBO_RESOURCE_PATH=/opt/gazebo/worlds
ENV GAZEBO_PLUGIN_PATH=/opt/gazebo/plugins

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Add Gazebo Harmonic repository
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# Install Gazebo Harmonic and dependencies
RUN apt-get update && apt-get install -y \
    gz-harmonic \
    && rm -rf /var/lib/apt/lists/*

# Install additional useful packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create directories for simulation assets
RUN mkdir -p /opt/gazebo/{worlds,models,plugins,assets}

# Copy entrypoint script
COPY docker/entrypoint.sh /opt/gazebo/entrypoint.sh

# Copy simulation assets
COPY worlds/ /opt/gazebo/worlds/
COPY models/ /opt/gazebo/models/
COPY plugins/ /opt/gazebo/plugins/
COPY assets/ /opt/gazebo/assets/
COPY scripts/ /opt/gazebo/scripts/

# Make scripts executable
RUN chmod +x /opt/gazebo/scripts/*.sh
RUN chmod +x /opt/gazebo/entrypoint.sh

# Set working directory
WORKDIR /opt/gazebo

# Expose ports for Gazebo communication
EXPOSE 11345

# Set entrypoint
ENTRYPOINT ["/opt/gazebo/entrypoint.sh"]
