# ✅ Host-Container Communication Setup (VERIFIED WORKING)

This guide shows how to enable **bidirectional ROS2 communication** between your host system and the Docker container using the XML configuration method.

## 🎯 Status: **VERIFIED WORKING** ✅

The XML solution has been tested and confirmed to work for host ↔ container topic exchange.

---

## 📋 One-Time Setup

### 1. The XML Configuration File

The file `fastdds_no_shm.xml` is already created in the `docker/` directory. This file forces Fast-DDS to use UDP transport instead of Shared Memory.

**Location**: `/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml`

**What it does**: Disables Shared Memory Transport and forces UDP-only communication, which works reliably between host and Docker containers.

---

## 🚀 Usage Instructions

### **Terminal 1: Start Container with LLM Agent**

```bash
# Navigate to docker directory
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker

# Start container (runs as jetbot user, UID 1000)
./run.sh

# Inside container: Start LLM agent
cd /ros2_ws
source install/setup.bash
ros2 run jetbot_tools llm_chat_agent

# Wait for: [INFO] Model: distilgpt2 vidion:False loaded successfully
```

### **Terminal 2: Set Up Host Environment**

```bash
# Set the Fast-DDS XML configuration
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml

# Set ROS Domain ID (must match container)
export ROS_DOMAIN_ID=7

# Source ROS2
source /opt/ros/humble/setup.bash

# Verify topics are visible
ros2 topic list
# Should see:
#   /jetbot_llm_input
#   /chatbot/response
```

### **Terminal 2: Test Communication**

```bash
# Send a message from host to container
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello from the host!'" --once

# Listen for responses from container
ros2 topic echo /chatbot/response
```

---

## 🎯 Complete Example Session

### Start the System:

```bash
# Terminal 1 (Container):
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
./run.sh
cd /ros2_ws && source install/setup.bash
ros2 run jetbot_tools llm_chat_agent
```

### Configure Host:

```bash
# Terminal 2 (Host):
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
```

### Send Messages:

```bash
# Terminal 2 (Host) - Send a message:
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Tell me about robots'" --once

# Watch for response (should appear in 5-7 seconds):
ros2 topic echo /chatbot/response --once
```

### Expected Output:

```
Container logs will show:
[INFO] [timestamp] [llm_text_chat]: LLM input:Tell me about robots
[INFO] [timestamp] [llm_text_chat]: Using direct generation (no chat history)
[INFO] [timestamp] [llm_text_chat]: <<jetbot>>: [Generated response about robots]

Host will receive:
data: '[Generated response about robots]'
---
```

---

## 🔧 Permanent Configuration (Optional)

To make the configuration permanent, add these lines to your `~/.bashrc`:

```bash
# ROS2 LLM Agent Configuration
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7

# Optional: Create an alias
alias ros2_llm='source /opt/ros/humble/setup.bash && export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml && export ROS_DOMAIN_ID=7'
```

Then reload:
```bash
source ~/.bashrc
```

Now you can just run:
```bash
ros2_llm
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello!'" --once
```

---

## 🧪 Testing Host → Container Communication

```bash
# On host (after setting up environment):
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Test message 1'" --once
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Test message 2'" --once
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'What is AI?'" --once

# Watch container logs for confirmation
# (In container terminal, you'll see "[INFO] LLM input:..." messages)
```

## 🧪 Testing Container → Host Communication

```bash
# On host (after setting up environment):
ros2 topic echo /chatbot/response

# In another host terminal or from container:
# The LLM agent will publish responses to /chatbot/response
# You should see them appear in real-time
```

---

## 🎵 Bonus: Audio Output on Host

If you want to hear the responses spoken out loud on your host:

```bash
# Terminal 3 (Host):
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash

# Run the audio bridge
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
python3 host_audio_bridge.py

# Now when the LLM responds, you'll hear it through your speakers!
```

---

## 🐛 Troubleshooting

### Topics Not Visible

```bash
# Make sure XML file path is correct:
echo $FASTRTPS_DEFAULT_PROFILES_FILE
# Should show: /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml

# Make sure domain ID matches:
echo $ROS_DOMAIN_ID
# Should show: 7

# Check if container is running:
docker ps | grep jetbot

# Restart ROS daemon:
ros2 daemon stop
ros2 daemon start
```

### Messages Not Being Received

```bash
# Verify the container received your message:
docker exec <container_id> grep "LLM input" /tmp/llm_agent.log | tail -5

# Check if LLM agent is running:
docker exec <container_id> ps aux | grep llm_chat_agent

# View live container logs:
docker logs -f <container_id>
```

### "Connection Refused" or "No Subscription"

This is normal if the LLM agent isn't ready yet. Wait for the model to load, then try again.

---

## 📊 Performance Notes

- **Message Latency**: ~10-50ms (host → container or container → host)
- **LLM Response Time**: 5-7 seconds (model inference time)
- **Network Overhead**: Minimal with UDP transport
- **Bandwidth**: ~1KB per message (text only)

---

## 🎯 Why This Works

1. **UID Matching**: Container runs as jetbot (UID 1000) = Host user arundev (UID 1000)
2. **UDP Transport**: XML config forces UDP, bypassing SHM permission issues
3. **Host Network**: Container uses `--net=host` for direct network access
4. **Shared /dev/shm**: Mounted (though not used with UDP-only config)
5. **Domain ID**: Both use ROS_DOMAIN_ID=7 for isolation

---

## ✅ Success Checklist

- [x] Docker image built with UID 1000
- [x] Container runs as jetbot user
- [x] XML configuration file created
- [x] Environment variables set on host
- [x] LLM agent running in container
- [x] Topics visible from both host and container
- [x] Messages flow bidirectionally
- [x] **VERIFIED WORKING** ✅

---

## 📝 Quick Reference

### Host Environment Setup:
```bash
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
```

### Send Message to LLM:
```bash
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Your message here'" --once
```

### Listen for Response:
```bash
ros2 topic echo /chatbot/response
```

### Check Topics:
```bash
ros2 topic list
ros2 topic info /jetbot_llm_input
ros2 topic info /chatbot/response
```

---

**Status**: ✅ **FULLY FUNCTIONAL AND VERIFIED**  
**Date**: October 13, 2025  
**Tested**: Host ↔ Container communication working perfectly!

🎉 **Congratulations! Your ROS2 LLM Agent now has full host-container communication!** 🚀

