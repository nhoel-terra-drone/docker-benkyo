IMAGE_TAG="jammy-docker"

docker run -it --rm \
       --name ros2_dev_container \
       -v $(pwd)/src:/root/ros2_ws/src \
       "$IMAGE_TAG" \
#       ros-fastlio-base \
       /bin/bash
#       /bin/bash -c ". /opt/ros/humble/setup.bash && colcon build --symlink-install && exec /bin/bash"
#        /bin/bash -c "source /opt/ros/humble/setup.bash && \
#                   echo '--- Running colcon build ---' && \
#                   colcon build --symlink-install; \
#                   echo '--- Build finished. Starting interactive shell ---' && \
#                   exec /bin/bash"

# . /opt/ros/humble/setup.bash
# colcon build --symlink-install
