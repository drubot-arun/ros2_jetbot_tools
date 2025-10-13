# 🚀 Quick Start Guide

## Start the LLM Agent (2 commands!)

```bash
# 1. Start container
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
./run.sh

# 2. Inside container - start LLM agent
cd /ros2_ws && source install/setup.bash && ros2 run jetbot_tools llm_chat_agent
```

Wait for: `[INFO] Model: distilgpt2 vidion:False loaded successfully`

## Test It (in another terminal)

```bash
# Get the container ID
docker ps

# Exec into the same container
docker exec -it <container_id> /bin/bash

# Inside container:
source /ros2_ws/install/setup.bash

# Send a message
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello, how are you?'" --once

# Watch for responses
ros2 topic echo /chatbot/response
```

## That's It! ✅

The LLM agent will:
- Receive your message
- Generate a response (5-7 seconds)
- Publish to `/chatbot/response`

---

## 🌐 Host-Container Communication (VERIFIED WORKING ✅)

Want to send messages from your host to the container?

```bash
# On host terminal:
export FASTRTPS_DEFAULT_PROFILES_FILE=/home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash

# Send messages from host!
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello from host!'" --once
ros2 topic echo /chatbot/response
```

**See `HOST_CONTAINER_SETUP.md` for complete details.**

---

## Need More?

- **Host communication**: See `HOST_CONTAINER_SETUP.md` ⭐ **VERIFIED WORKING**
- **Full documentation**: See `SUCCESS_SUMMARY.md`
- **DDS solutions**: See `DDS_SOLUTION_FINAL.md`
- **Demo script**: Run `./demo_llm_agent.sh`
- **Troubleshooting**: See `SOLUTION.md`

---

**Pro Tip**: Keep the LLM agent running in one terminal, and use another terminal with the XML config to send messages from your host!

