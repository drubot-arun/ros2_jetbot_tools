# ROS2 JetBot LLM Agent 🤖

**A fully functional ROS2-based LLM agent with audio output for NVIDIA Jetson Orin**

## ✅ Status: Production Ready

All systems operational and tested:
- ✅ Docker container with UID 1000
- ✅ LLM model loading and inference
- ✅ Host ↔ Container ROS2 communication
- ✅ Audio output via espeak TTS
- ✅ Complete end-to-end pipeline

---

## 🚀 Quick Start

### 1. Start Container & LLM Agent
```bash
cd ~/ros2_workspace/src/ros2_jetbot_tools/docker
./run.sh

# Inside container:
cd /ros2_ws && source install/setup.bash
ros2 run jetbot_tools llm_chat_agent
```

### 2. Chat with Your Robot (from Host)
```bash
export FASTRTPS_DEFAULT_PROFILES_FILE=~/ros2_workspace/src/ros2_jetbot_tools/docker/fastdds_no_shm.xml
export ROS_DOMAIN_ID=7
source /opt/ros/humble/setup.bash
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'Hello!'" --once

# View response:
ros2 topic echo /chatbot/response --once
```

**Optional:** For audio output on host, see `AUDIO_TEST_GUIDE.md`

---

## 📁 Documentation

| Guide | Description |
|-------|-------------|
| **QUICK_START.md** | Get started in 2 commands |
| **HOST_CONTAINER_SETUP.md** | Complete host-container communication setup |
| **AUDIO_TEST_GUIDE.md** | Audio system testing and troubleshooting |
| **GATED_MODELS_GUIDE.md** | Using better LLM models (Llama, Phi, etc.) |
| **FINAL_SUCCESS.md** | Complete technical summary & achievements |

---

## 🔧 Key Files

| File | Purpose |
|------|---------|
| `run.sh` | Start Docker container (as jetbot user UID 1000) |
| `host_audio_bridge.py` | Audio bridge for TTS output on host |
| `fastdds_no_shm.xml` | DDS configuration for host-container communication |
| `Dockerfile` | Container definition with all dependencies |
| `build.sh` | Build Docker image |

---

## 📊 System Architecture

```
Host System:
  ├─ You send text → /jetbot_llm_input
  │                    ↓ (Fast-DDS with XML config)
  └─ Docker Container (UID 1000):
      ├─ LLM Agent receives & processes
      ├─ Generates AI response (5-7 sec)
      └─ Publishes → /chatbot/response
                      ↓ (Fast-DDS with XML config)
     Audio Bridge:
      └─ espeak → 🔊 Speakers
```

---

## 🎯 Features

- **LLM Model**: distilgpt2 (upgradable to Llama, Phi, etc.)
- **GPU Acceleration**: NVIDIA TensorRT via NanoLLM
- **Audio Output**: espeak text-to-speech
- **ROS2 Integration**: Full topic-based communication
- **Docker**: Isolated environment with proper permissions
- **UID Matching**: Container runs as UID 1000 for DDS compatibility

---

## 🔧 Requirements

- NVIDIA Jetson Orin
- Ubuntu 20.04
- ROS2 Humble
- Docker with NVIDIA runtime
- ~8GB RAM for LLM inference
- Speakers/audio output

---

## 🎓 Usage Examples

### Send a question:
```bash
ros2 topic pub /jetbot_llm_input std_msgs/msg/String "data: 'What is robotics?'" --once
```

### Use better model:
```bash
ros2 run jetbot_tools llm_chat_agent --ros-args -p model:="TinyLlama/TinyLlama-1.1B-Chat-v1.0"
```

### Run as root (if needed):
```bash
./run.sh root
```

---

## 🐛 Troubleshooting

### No audio output?
- Check speaker volume: `alsamixer`
- Test espeak: `echo "test" | espeak`
- See: `AUDIO_TEST_GUIDE.md`

### Topics not visible?
- Restart ROS daemon: `ros2 daemon stop && ros2 daemon start`
- Verify XML path: `echo $FASTRTPS_DEFAULT_PROFILES_FILE`
- See: `HOST_CONTAINER_SETUP.md`

### Model too slow?
- Try smaller model: `TinyLlama/TinyLlama-1.1B-Chat-v1.0`
- See: `GATED_MODELS_GUIDE.md`

---

## 🎉 Credits

- Base Image: [dustynv/nano_llm](https://github.com/dusty-nv/NanoLLM)
- Framework: ROS2 Humble
- Platform: NVIDIA Jetson Orin
- LLM Engine: NanoLLM
- DDS Solution: Based on [Stack Overflow discussion](https://stackoverflow.com/questions/65900201/)

---

## 📝 License

Check individual component licenses:
- NanoLLM: Apache 2.0
- ROS2: Apache 2.0
- Models: See HuggingFace model cards

---

**Status**: ✅ Fully Operational  
**Version**: 1.0  
**Date**: October 13, 2025

🤖 **Your intelligent, talking robot awaits!** 🚀

