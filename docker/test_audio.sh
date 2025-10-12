#!/bin/bash
# Test script to verify Docker container audio functionality

echo "Testing Docker container audio functionality..."

# Run container in detached mode first
CONTAINER_ID=$(docker run --runtime nvidia -d --rm --net host --ipc host \
    --volume=/tmp/.X11-unix/:/tmp/.X11-unix:rw \
    --volume /tmp/argus_socket:/tmp/argus_socket \
    --volume=/home/arundev/ros2_workspace/src/ros2_jetbot_tools:/ros2_ws/src/ros2_jetbot_tools \
    --volume=/home/arundev/.ros/log:/.ros/log \
    --volume=/ros2_ws:/ros2_ws \
    --volume /tmp/pulse:/tmp/pulse \
    --volume /dev/snd:/dev/snd \
    --volume /etc/asound.conf:/etc/asound.conf:ro \
    --volume /usr/share/alsa:/usr/share/alsa:ro \
    --env DISPLAY=$DISPLAY \
    --env QT_X11_NO_MITSHM=1 \
    --env ROS_DOMAIN_ID=7 \
    --env PULSE_RUNTIME_PATH=/tmp/pulse \
    --env PULSE_COOKIE_DATA=/tmp/pulse/cookie \
    --device /dev/bus/usb \
    --device=/dev/input \
    jetbot_nano_llm:latest \
    /bin/bash -c "cd /ros2_ws && colcon build --symlink-install --packages-select jetbot_tools && source install/setup.bash && sleep infinity")

echo "Container started with ID: $CONTAINER_ID"

# Wait a moment for container to initialize
sleep 5

# Test audio functionality
echo "Testing audio devices..."
docker exec $CONTAINER_ID aplay -l

echo "Testing ALSA configuration..."
docker exec $CONTAINER_ID cat /etc/asound.conf

echo "Testing speaker-test..."
docker exec $CONTAINER_ID speaker-test -D hw:1 -t sine -f 1000 -l 1

echo "Testing espeak..."
docker exec $CONTAINER_ID espeak "Hello, this is a test of text to speech"

echo "Cleaning up..."
docker stop $CONTAINER_ID

echo "Test completed!"

