# Use an argument for the base image
ARG BASE_IMAGE=dustynv/nano_llm:humble-r36.3.0
FROM ${BASE_IMAGE}

# Use arguments for user, group IDs, and username
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=jetbot

# Create a new user with specified user id, group id, and username
RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
    useradd -u ${USER_ID} -g ${USERNAME} -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME}:${USERNAME}" | chpasswd && \
    adduser ${USERNAME} sudo && \
    (getent group video || groupadd -r video) && \
    (getent group audio || groupadd -r audio) && \
    usermod -aG video,audio ${USERNAME}


# Change the ownership of the home directory to the new user
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Create the necessary directory
RUN mkdir -p /home/${USERNAME}/.cache/clip_trt && \
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.cache

# Change the ownership of /opt/jetson-inference, /ros2_workspace, /opt/NanoLLM, /opt/clip_trt, and /opt/NanoDB to the new user
RUN chown -R ${USERNAME}:${USERNAME} /opt/jetson-inference /ros2_workspace /opt/NanoLLM /opt/clip_trt /opt/NanoDB


# Create the working directory
RUN mkdir -p /test

# Set the working directory in the Docker image
WORKDIR /test

# Copy requirements.txt to the working directory
COPY requirements.txt /test/requirements.txt

# Add this before any apt update commands
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add -
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Update the package list and install PyKDL and audio tools
RUN apt-get update && apt-get install -y \
    liborocos-kdl-dev \
    python3-pykdl \
    alsa-utils \
    espeak-ng \
    pulseaudio-utils \
    kmod

# Update the package list and install vi
RUN apt-get install -y vim

# Install any necessary dependencies
RUN pip install --no-cache-dir -r /test/requirements.txt

# Configure audio system - use HDA card (card 1) as default
RUN echo 'pcm.!default {\n    type hw\n    card 1\n    device 0\n}\nctl.!default {\n    type hw\n    card 1\n}' > /etc/asound.conf

# Create symlink for espeak
RUN ln -sf /usr/bin/espeak-ng /usr/bin/espeak

# Set PYTHONPATH environment variable for both users
ENV PYTHONPATH=/opt/NanoLLM:/opt/clip_trt:/opt/NanoDB:$PYTHONPATH


# Set up the ROS2 workspace
RUN mkdir -p /ros2_ws/src
WORKDIR /ros2_ws/src

# Set the default shell
ENV SHELL=/bin/bash

# Set the default command
CMD ["/bin/bash"]
