#!/bin/bash
# Test script to verify ROS2 audio bridge functionality

echo "🧪 Testing ROS2 Audio Bridge..."

# Set ROS_DOMAIN_ID
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash

# Kill any existing audio bridge processes
pkill -f "host_audio_bridge" 2>/dev/null
pkill -f "host_tts_bridge" 2>/dev/null

echo "🔊 Starting audio bridge..."
python3 /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/host_audio_bridge.py &
AUDIO_PID=$!

echo "⏳ Waiting for audio bridge to initialize..."
sleep 2

echo "📡 Testing topic communication..."
ros2 topic pub /chatbot/response std_msgs/msg/String "data: 'Testing audio bridge communication'" --once

echo "⏳ Waiting for audio to play..."
sleep 3

echo "🧹 Cleaning up..."
kill $AUDIO_PID 2>/dev/null

echo "✅ Test completed!"

