#!/bin/bash
# Complete solution for ROS2 JetBot Tools with Host Audio Bridge

echo "🚀 Starting ROS2 JetBot Tools with Host Audio Bridge..."

# Check if espeak is installed on host
if ! command -v espeak &> /dev/null; then
    echo "📦 Installing espeak on host..."
    sudo apt update && sudo apt install -y espeak
fi

# Check if ROS2 is installed on host
if ! command -v ros2 &> /dev/null; then
    echo "📦 Installing ROS2 on host..."
    sudo apt install -y ros-humble-desktop
fi

# Start the Docker container in detached mode
echo "🐳 Starting Docker container..."
CONTAINER_ID=$(docker run --runtime nvidia -d --rm --net host --ipc host \
    --volume=/tmp/.X11-unix/:/tmp/.X11-unix:rw \
    --volume /tmp/argus_socket:/tmp/argus_socket \
    --volume=/home/arundev/ros2_workspace/src/ros2_jetbot_tools:/ros2_ws/src/ros2_jetbot_tools \
    --volume=/home/arundev/.ros/log:/.ros/log \
    --volume=/ros2_ws:/ros2_ws \
    --volume /tmp/pulse:/tmp/pulse \
    --volume /dev/snd:/dev/snd \
    --env DISPLAY=$DISPLAY \
    --env QT_X11_NO_MITSHM=1 \
    --env ROS_DOMAIN_ID=7 \
    --env PULSE_RUNTIME_PATH=/tmp/pulse \
    --env PULSE_COOKIE_DATA=/tmp/pulse/cookie \
    --device /dev/bus/usb \
    --device=/dev/input \
    jetbot_nano_llm:latest \
    /bin/bash -c "cd /ros2_ws && colcon build --symlink-install --packages-select jetbot_tools && source install/setup.bash && sleep infinity")

echo "✅ Container started with ID: $CONTAINER_ID"

# Wait for container to initialize
echo "⏳ Waiting for container to initialize..."
sleep 10

# Start the host audio bridge
echo "🔊 Starting Host Audio Bridge..."
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
python3 /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/host_audio_bridge.py &
AUDIO_BRIDGE_PID=$!

echo "✅ Host Audio Bridge started with PID: $AUDIO_BRIDGE_PID"

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    kill $AUDIO_BRIDGE_PID 2>/dev/null
    docker stop $CONTAINER_ID 2>/dev/null
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

echo ""
echo "🎯 ROS2 JetBot Tools is ready!"
echo "📋 Available commands:"
echo "   • Connect to container: docker exec -it $CONTAINER_ID /bin/bash"
echo "   • Run LLM chat: docker exec -it $CONTAINER_ID /bin/bash -c 'cd /ros2_ws && source install/setup.bash && ros2 run jetbot_tools llm_chat_agent'"
echo "   • Run voice copilot: docker exec -it $CONTAINER_ID /bin/bash -c 'cd /ros2_ws && source install/setup.bash && ros2 run jetbot_tools voice_copilot'"
echo ""
echo "🔊 Audio will be played through the host system"
echo "⏹️  Press Ctrl+C to stop everything"
echo ""

# Keep the script running
while true; do
    sleep 1
done
