#!/bin/bash
# Test script to verify complete topic communication

echo "🧪 Testing Complete Topic Communication..."

# Set ROS_DOMAIN_ID
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash

echo "📡 Step 1: Publishing to LLM input topic..."
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello, can you hear me?'" --once

echo "⏳ Step 2: Waiting for LLM response..."
sleep 3

echo "📡 Step 3: Checking for response on output topic..."
timeout 5 ros2 topic echo /chatbot/response --once || echo "No response received"

echo "📡 Step 4: Testing direct audio bridge..."
ros2 topic pub /chatbot/response std_msgs/msg/String "data: 'Direct test message to audio bridge'" --once

echo "✅ Test completed!"
