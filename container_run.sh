docker run -it --rm \
       -v $(pwd)/src:/root/ros2_ws/src \
       ros-fastlio-base \
       /bin/bash -c ". /opt/ros/humble/setup.bash && colcon build --symlink-install && exec /bin/bash"
