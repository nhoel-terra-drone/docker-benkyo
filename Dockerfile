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
RUN apt update && apt upgrade -y 

# 2.5 Install Build and Core Libraries
RUN apt install -y libpcl-dev \
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