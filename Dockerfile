# Start with a pre-built ROS2 base image
FROM amd64/ros:humble-ros-base-jammy

# 1. Locale setup (necessary for ROS/Apt to work correctly)
ENV DEBIAN_FRONTEND=noninteractive
#RUN apt update && apt install -y locales curl software-properties-common
RUN apt update && apt install -y locales

# Note: ros-base image already has basic local setup
#RUN locale-gen en_US en_US.UTF-8
#ENV LANG=en_US.UTF-8
#ENV LC_ALL=en_US.UTF-8

# 2. Add System Dependencies
# Dependencies must be installed in the image since they are not mounted at runtime
RUN apt update && apt upgrade -y --fix-missing

# 2.5 Install Build and Core Libraries
RUN apt install -y --no-install-recommends \
                   libpcl-dev \
                   libeigen3-dev \
                   # Add other common tools needed for development/building packages
                   g++ cmake git \
                   python3-rosdep python3-colcon-common-extensions \
                   # ROS dependecies installed as system package
                   ros-humble-pcl-conversions \
                   ros-humble-pcl-ros \
                   ros-dev-tools \
                   # Other utilities
                   curl software-properties-common

ARG SNAPSHOT_DATE=2024-12-20
ARG ROS_DISTRO_NAME=humble
ARG ROSBRIDGE_VERSION=2.0.0-1jammy*

# A. Add the ONLY valid ROS snapshot repo
RUN echo "deb [arch=$(dpkg --print-architecture) trusted=yes] http://snapshots.ros.org/${ROS_DISTRO_NAME}/${SNAPSHOT_DATE}/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2-snapshot.list

# B. Update apt to recognize the snapshot
RUN apt update

# C. Create an Apt Pinning file to prioritize the *specific version*
# This file tells apt to prefer the exact version we want. 
# Pin-Priority: 1001 forces installation even if it's considered a "downgrade."
RUN echo "Package: ros-humble-rosbridge-suite" > /etc/apt/preferences.d/ros2-snapshot-pin
RUN echo "Pin: version ${ROSBRIDGE_VERSION}" >> /etc/apt/preferences.d/ros2-snapshot-pin
RUN echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/ros2-snapshot-pin

# C. Install pinned versions explicitly
RUN apt-get update && \
    apt-get install -y \
        ros-humble-rosbridge-server=${ROSBRIDGE_VERSION} \
        ros-humble-rosbridge-suite=${ROSBRIDGE_VERSION} && \
    apt-mark hold \
        ros-humble-rosbridge-server \
        ros-humble-rosbridge-suite && \
    rm -rf /var/lib/apt/lists/*

# D. Remove snapshot + pinning to prevent accidental downgrades later
RUN rm /etc/apt/sources.list.d/ros2-snapshot.list && \
    rm /etc/apt/preferences.d/ros2-snapshot-pin && \
    apt-get update

# 3. ROS workspace setup
WORKDIR /root/ros2_ws
RUN mkdir -p src

# 4. Handle ROS Dependencies
RUN rosdep init || true
RUN rosdep update

# 5. Set Environment for Subsequent Runs
# The ROS 2 setup file is already in the ros-base image
RUN echo ". /opt/ros/humble/setup.bash" >> /root/.bashrc

# Set the default command to bash
CMD ["/bin/bash"]