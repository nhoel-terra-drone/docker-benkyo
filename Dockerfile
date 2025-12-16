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

# ----------------------------------------------------
# FIX: Use Snapshot Repository for Specific Version
# ----------------------------------------------------
# Define the date of the snapshot (Adjust as needed)
# ARG SNAPSHOT_DATE=2025-04-25
# ARG ROS_DISTRO_NAME=humble

# # A. Temporarily add the snapshot repository to sources.list
# #RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://snapshots.ros.org/${ROS_DISTRO_NAME}/${SNAPSHOT_DATE}/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2-snapshot.list
# RUN echo "deb [arch=$(dpkg --print-architecture) trusted=yes] http://snapshots.ros.org/${ROS_DISTRO_NAME}/${SNAPSHOT_DATE}/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2-snapshot.list
# 
# # B. Update apt to recognize the snapshot
# RUN apt update
# 
# # C. Install the exact version from the snapshot
# RUN apt install -y ros-humble-rosbridge-suite=2.0.0-1jammy*
# 
# # D. Remove the snapshot entry to prevent accidental installation of old packages later
# RUN rm /etc/apt/sources.list.d/ros2-snapshot.list
# 
# # E. Run apt update to revert to only using the official
# RUN apt update

#ARG SNAPSHOT_DATE=2025-04-25
ARG SNAPSHOT_DATE=2024-12-20
ARG ROS_DISTRO_NAME=humble
ARG ROSBRIDGE_VERSION=2.0.0-1jammy*

# A. Temporarily add the snapshot repository to sources.list
RUN echo "deb [arch=$(dpkg --print-architecture) trusted=yes] http://snapshots.ros.org/${ROS_DISTRO_NAME}/${SNAPSHOT_DATE}/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/ros2-snapshot.list

# B. Update apt to recognize the snapshot
RUN apt update

# C. Create an Apt Pinning file to prioritize the *specific version*
# This file tells apt to prefer the exact version we want. 
# Pin-Priority: 1001 forces installation even if it's considered a "downgrade."
RUN echo "Package: ros-humble-rosbridge-suite" > /etc/apt/preferences.d/ros2-snapshot-pin
RUN echo "Pin: version ${ROSBRIDGE_VERSION}" >> /etc/apt/preferences.d/ros2-snapshot-pin
RUN echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/ros2-snapshot-pin

# D. Install the package. The pin ensures the requested version is chosen.
# Using the specific version in the install command is still best practice.
RUN apt install -y ros-humble-rosbridge-suite=${ROSBRIDGE_VERSION}

# E. Remove the pinning and the snapshot source
RUN rm /etc/apt/preferences.d/ros2-snapshot-pin
RUN rm /etc/apt/sources.list.d/ros2-snapshot.list

# F. Run apt update to revert to only using the official repository indices
RUN apt update

# 3. Setup ROS2 Workspace Structure (establish paths)
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