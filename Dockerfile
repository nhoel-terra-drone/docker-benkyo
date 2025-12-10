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

# 2. Add ROS 2 Repository (Replaces the broken manual .deb download)
RUN apt update && apt install -y lsb-release
# Add ROS 2 GPG key
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
# Add the ROS 2 repository source list (for Humble on Jammy)
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 2.5 Add System Dependencies
RUN apt install -y libpcl-dev \
                   libeigen3-dev \
                   # Add other common tools needed for development/building packages
                   g++ cmake

# 3. Install ROS 2 Humble
RUN apt update
RUN apt upgrade -y
RUN apt install -y ros-humble-desktop
RUN apt install -y ros-dev-tools

# 4. Install Livox ROS Driver 2 Git Repo
# Set up the ROS 2 Workspace structure
WORKDIR /root/ros2_ws
RUN mkdir -p src

# Clone External Dependencies (livox_ros_driver2)
# Change the working directory to the 'src' folder
WORKDIR /root/ros2_ws/src
# Clone the specific branch using git clone
RUN git clone https://github.com/Ericsii/livox_ros_driver2.git

# Build the Workspace
# Change back to the workspace root for colcon build
WORKDIR /root/ros2_ws
# Source the ROS 2 setup file and build the workspace
RUN ["/bin/bash", "-c", ". /opt/ros/humble/setup.bash && colcon build --symlink-install"]

# Set Environment for Subsequent Runs
# Add the workspace setup to the bash profile so it's sourced automatically
RUN echo ". /root/ros2_ws/install/setup.bash" >> /root/.bashrc

# 5. Install FAST_LIO Git Repo

# Install ROS 2 PCL dependencies explicitly
RUN apt update && apt install -y ros-humble-pcl-conversions ros-humble-pcl-ros

# Set up the ROS 2 Workspace structure
WORKDIR /root/ros2_ws
RUN mkdir -p src
WORKDIR /root/ros2_ws/src
RUN git clone https://github.com/Ericsii/FAST_LIO.git --recursive

# Set up ROS Dependencies
WORKDIR /root/ros2_ws
RUN rosdep init && rosdep update
RUN ["/bin/bash", "-c", "export ROS_DISTRO=humble && rosdep install --from-paths src --ignore-src -y"]
#RUN ["/bin/bash", "-c", ". ./install.setup.bash && colcon build --symlink-install"]
RUN ["/bin/bash", "-c", ". /opt/ros/humble/setup.bash && colcon build --symlink-install"]

RUN echo ". /root/ros2_ws/install/setup.bash" >> /root/.bashrc

# Set the default command to bash
CMD ["/bin/bash"] 