# 🎵 Audio Output Test Guide

## ✅ System Status: WORKING

- Docker Image: ✅ Built with UID 1000
- DDS Communication: ✅ XML configuration working
- Audio Bridge: ✅ Ready to test

---

## 🚀 Complete Audio Test Procedure

### **Terminal 1: Start Container and LLM Agent**

```bash
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
./run.sh

# Inside container:
cd /ros2_ws
source install/setup.bash
ros2 run jetbot_tools llm_chat_agent

# Wait for: [INFO] Model: distilgpt2 vidion:False loaded successfully
```

### **Terminal 2: Start Audio Bridge on Host**

```bash
# Set up environment with XML config
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash

# Start ROS daemon with config
ros2 daemon stop
ros2 daemon start

# Verify topics are visible
ros2 topic list | grep -E "(jetbot|chatbot)"

# Start audio bridge (subscribes to /chatbot/response and plays via espeak)
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
python3 host_audio_bridge.py

# You should see: "Audio bridge ready. Listening for responses..."
```

### **Terminal 3: Send Test Messages**

```bash
# Set up environment
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash

# Send test messages to LLM
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello, how are you?'" --once

# Wait 5-10 seconds - you should hear the response through your speakers!

# Try more messages:
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Tell me a joke'" --once
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'What is artificial intelligence?'" --once
```

---

## 🧪 Testing Audio Bridge Directly

To test if the audio bridge is working (bypassing the LLM):

```bash
# Terminal with audio bridge running:
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash

# Publish directly to response topic
ros2 topic pub /chatbot/response std_msgs/msg/String "data: 'This is a test of the audio system'" --once

# You should hear: "This is a test of the audio system"
```

---

## 📊 Expected Behavior

1. **You send a message** via `/jetbot_llm_input`
2. **LLM receives it** (logs show "LLM input: ...")
3. **LLM generates response** (takes 5-7 seconds)
4. **LLM publishes to** `/chatbot/response`
5. **Audio bridge receives it**
6. **espeak plays the text** through your speakers
7. **You hear the response!** 🎵

---

## 🐛 Troubleshooting

### No Audio Output

**Check speaker volume:**
```bash
alsamixer
# Press F6 to select sound card
# Adjust volume with arrow keys
```

**Test espeak directly:**
```bash
echo "Testing speakers" | espeak
```

**Check if audio bridge is running:**
```bash
ps aux | grep host_audio_bridge
```

**Restart audio bridge:**
```bash
# Kill old process
pkill -f host_audio_bridge

# Start new one
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
python3 host_audio_bridge.py
```

### Bridge Not Receiving Messages

**Check ROS daemon:**
```bash
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
ros2 daemon stop
ros2 daemon start
```

**Verify topics:**
```bash
ros2 topic list | grep chatbot
ros2 topic echo /chatbot/response  # Should show messages
```

### LLM Not Responding

**Check if LLM agent is running:**
```bash
docker ps
docker exec <container_id> ps aux | grep llm_chat_agent
```

**Check LLM logs:**
```bash
docker exec <container_id> cat /tmp/llm_agent.log
# OR
docker logs <container_id>
```

**Restart LLM agent:**
```bash
docker exec -it <container_id> /bin/bash
cd /ros2_ws && source install/setup.bash
ros2 run jetbot_tools llm_chat_agent
```

---

## 📝 Quick Commands Reference

### Start Everything:
```bash
# Terminal 1 - Container
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker && ./run.sh

# Terminal 2 - Audio Bridge
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
python3 host_audio_bridge.py

# Terminal 3 - Send Messages
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello!'" --once
```

### Stop Everything:
```bash
# Stop audio bridge
pkill -f host_audio_bridge

# Stop LLM agent (inside container)
pkill -f llm_chat_agent

# Stop container
docker stop $(docker ps -q --filter ancestor=jetbot_nano_llm:latest)
```

---

## 🎯 What Each Component Does

| Component | Purpose | Location |
|-----------|---------|----------|
| **LLM Agent** | Processes text, generates responses | Inside container |
| **Audio Bridge** | Subscribes to responses, plays audio | Host system |
| **espeak** | Text-to-speech engine | Host system |
| **Fast-DDS XML** | Enables host-container communication | Host + Container |
| **ROS Topics** | Message passing between components | Network |

---

## 💡 Tips

1. **Keep audio bridge running** - It continuously listens for responses
2. **Adjust volume** before testing - Use `alsamixer`
3. **Test espeak first** - Make sure basic audio works
4. **Check ROS_DOMAIN_ID** - Must be 7 on both host and container
5. **Use `--once`** for topic pub - Cleaner than continuous publishing

---

## ✨ Success Indicators

You'll know it's working when:
- ✅ Audio bridge shows "Listening for responses..."
- ✅ You send a message via `ros2 topic pub`
- ✅ After 5-10 seconds, you **hear the LLM's response** through your speakers
- ✅ The response is related to your question

---

## 📚 Related Documentation

- **Host Communication Setup**: `HOST_CONTAINER_SETUP.md`
- **DDS Solutions**: `DDS_SOLUTION_FINAL.md`
- **Quick Start**: `QUICK_START.md`
- **Complete Summary**: `SUCCESS_SUMMARY.md`

---

**Status**: ✅ Audio system ready for testing  
**Last Updated**: October 13, 2025  
**Component**: Audio Bridge with espeak TTS

🎵 **Enjoy your talking robot!** 🤖

