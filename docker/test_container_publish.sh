#!/bin/bash
# Script to publish messages from Docker container to test audio bridge

CONTAINER_ID=$(docker ps --filter ancestor=jetbot_nano_llm:latest --format "{{.ID}}" | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "❌ No jetbot_nano_llm container found!"
    echo "Please run: ./start_with_audio.sh"
    exit 1
fi

echo "🐳 Publishing from container: $CONTAINER_ID"

# Function to publish a message
publish_message() {
    local message="$1"
    echo "📡 Publishing: $message"
    docker exec $CONTAINER_ID /bin/bash -c "cd /ros2_ws && source install/setup.bash && ros2 topic pub /chatbot/response std_msgs/msg/String 'data: $message' --once"
}

# Test messages
echo "🧪 Testing audio bridge with different messages..."

publish_message "Hello! This is a test from the Docker container."
sleep 2

publish_message "The audio bridge is working perfectly!"
sleep 2

publish_message "You should hear this message through your speakers."
sleep 2

publish_message "ROS2 communication between container and host is successful!"

echo "✅ Test completed! Check if you heard the audio messages."

