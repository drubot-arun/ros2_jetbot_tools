# 🔐 Using Gated Models (Llama, Phi, etc.)

## Why Upgrade from distilgpt2?

**Current Model**: `distilgpt2` (82M parameters)
- ❌ Not instruction-tuned
- ❌ Limited context understanding
- ❌ Often repetitive or nonsensical
- ✅ Fast and lightweight

**Better Models**:
- ✅ Instruction-tuned for conversations
- ✅ Better context understanding
- ✅ More coherent responses
- ✅ Follow instructions accurately

---

## 🎯 Recommended Models for Jetson Orin

### **Tier 1: Best Performance (Recommended)**

| Model | Size | Access | Quality | Speed |
|-------|------|--------|---------|-------|
| **microsoft/Phi-3-mini-4k-instruct** | 3.8B | Open ✅ | Excellent | Fast |
| **TinyLlama/TinyLlama-1.1B-Chat-v1.0** | 1.1B | Open ✅ | Very Good | Very Fast |
| **stabilityai/stablelm-2-zephyr-1_6b** | 1.6B | Open ✅ | Excellent | Fast |

### **Tier 2: Premium (Gated - Requires Access)**

| Model | Size | Access | Quality | Speed |
|-------|------|--------|---------|-------|
| **meta-llama/Llama-2-7b-chat-hf** | 7B | Gated 🔒 | Excellent | Medium |
| **meta-llama/Llama-3.2-3B-Instruct** | 3B | Gated 🔒 | Excellent | Fast |
| **mistralai/Mistral-7B-Instruct-v0.2** | 7B | Open ✅ | Excellent | Medium |

---

## 📋 Step-by-Step: Getting Access to Gated Models

### **Step 1: Create HuggingFace Account**

1. Go to: https://huggingface.co/join
2. Sign up with email
3. Verify your email address

### **Step 2: Request Access to Gated Model**

**For Llama Models:**

1. Go to model page (example):
   - Llama 2: https://huggingface.co/meta-llama/Llama-2-7b-chat-hf
   - Llama 3.2: https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct

2. Click **"Request Access"** button (red banner at top)

3. Fill out the form:
   - Accept Meta's license agreement
   - Provide your intended use case
   - Submit request

4. **Wait for approval** (usually instant to 24 hours)
   - Check your email for approval notification
   - Refresh model page - "Request Access" should change to "Use this model"

### **Step 3: Create Access Token**

1. Go to: https://huggingface.co/settings/tokens

2. Click **"New token"**

3. Configure token:
   - **Name**: `jetson_llm_access` (or any name)
   - **Type**: Select **"Read"** (sufficient for downloading models)
   - **Repositories**: Leave as "All" or select specific models

4. Click **"Generate token"**

5. **IMPORTANT**: Copy the token immediately!
   - Format: `hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - It will look like: `hf_AbCdEfGhIjKlMnOpQrStUvWxYz1234567890`
   - You won't be able to see it again!

6. **Save it securely** (you'll need it for next step)

---

## 🔧 Step 4: Configure Your System with the Token

### **Option A: Set Environment Variable (Temporary)**

```bash
# In your terminal (valid for current session only):
export HUGGINGFACE_TOKEN="hf_your_token_here"

# Start container with token:
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
./run.sh
```

### **Option B: Add to .bashrc (Permanent - Recommended)**

```bash
# Edit your bashrc:
nano ~/.bashrc

# Add this line at the end:
export HUGGINGFACE_TOKEN="hf_your_token_here"

# Save and exit (Ctrl+X, Y, Enter)

# Reload:
source ~/.bashrc

# Verify:
echo $HUGGINGFACE_TOKEN
```

### **Option C: Store in Credentials File (Most Secure)**

```bash
# Login using huggingface-cli (inside container):
pip install -U huggingface_hub

# Login interactively:
huggingface-cli login

# Paste your token when prompted
# Token will be saved to ~/.cache/huggingface/token
```

---

## 🚀 Step 5: Update LLM Agent to Use Better Model

### **Method 1: Change Default in Code**

Edit `llm_chat_agent.py`:

```bash
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/jetbot_tools/script
nano llm_chat_agent.py
```

Find this line (around line 60):
```python
self.llm_model = self.declare_parameter('model', 'distilgpt2').get_parameter_value().string_value
```

Change to:
```python
# For open model (no token needed):
self.llm_model = self.declare_parameter('model', 'TinyLlama/TinyLlama-1.1B-Chat-v1.0').get_parameter_value().string_value

# OR for gated model (token required):
self.llm_model = self.declare_parameter('model', 'meta-llama/Llama-2-7b-chat-hf').get_parameter_value().string_value
```

Rebuild:
```bash
cd /ros2_ws
colcon build --symlink-install --packages-select jetbot_tools
```

### **Method 2: Pass as ROS Parameter (No Code Change)**

```bash
# Start with custom model:
ros2 run jetbot_tools llm_chat_agent --ros-args -p model:="TinyLlama/TinyLlama-1.1B-Chat-v1.0"

# OR for Llama:
ros2 run jetbot_tools llm_chat_agent --ros-args -p model:="meta-llama/Llama-2-7b-chat-hf"
```

---

## 📊 Model Comparison & Recommendations

### **For Fastest Response (< 3 seconds):**
```python
model = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"  # Open, no token needed
# Quality: Very Good
# Speed: Very Fast
# Memory: ~1.5GB
```

### **For Best Quality/Speed Balance:**
```python
model = "microsoft/Phi-3-mini-4k-instruct"  # Open, no token needed
# Quality: Excellent
# Speed: Fast
# Memory: ~4GB
```

### **For Production Quality (if you have access):**
```python
model = "meta-llama/Llama-2-7b-chat-hf"  # Gated, needs token
# Quality: Excellent
# Speed: Medium (~7 seconds)
# Memory: ~7GB
```

### **For Latest & Best (if you have access):**
```python
model = "meta-llama/Llama-3.2-3B-Instruct"  # Gated, needs token
# Quality: Excellent
# Speed: Fast (~4 seconds)
# Memory: ~3GB
```

---

## 🧪 Testing New Models

### **Test Script:**

```bash
# Start container with token
export HUGGINGFACE_TOKEN="hf_your_token_here"
cd /home/arundev/ros2_workspace/src/ros2_jetbot_tools/docker
./run.sh

# Inside container, test model loading:
cd /ros2_ws && source install/setup.bash

# Test with parameter:
ros2 run jetbot_tools llm_chat_agent --ros-args \
  -p model:="TinyLlama/TinyLlama-1.1B-Chat-v1.0"

# Watch for: "Model: TinyLlama/... loaded successfully"
```

---

## ⚠️ Troubleshooting

### **Error: "Cannot access gated repo"**

**Solution:**
1. Make sure you requested and received access on HuggingFace
2. Verify token is set: `echo $HUGGINGFACE_TOKEN`
3. Check token has "read" permissions
4. Try logging in with `huggingface-cli login`

### **Error: "CUDA out of memory"**

**Solution:**
- Model is too large for your GPU
- Try smaller model (TinyLlama instead of Llama-2-7b)
- Reduce quantization: `q4f16_ft` → `q4f32_ft`
- Close other GPU applications

### **Model Downloads Very Slowly**

**Solution:**
- Models are large (1GB - 15GB)
- First download takes time (cached after)
- Models stored in: `/data/models/huggingface/`
- Check disk space: `df -h /data`

### **Error: "Couldn't determine model type"**

**Solution:**
- Some models need specific chat templates
- Try removing chat_template parameter
- Or explicitly set: `chat_template='llama-2'`
- See `llm_chat_agent.py` line 120

---

## 💡 Pro Tips

### **1. Pre-download Models**

Download models before running to avoid wait time:

```bash
# Inside container:
python3 -c "from transformers import AutoModelForCausalLM, AutoTokenizer; \
  model_name='TinyLlama/TinyLlama-1.1B-Chat-v1.0'; \
  AutoModelForCausalLM.from_pretrained(model_name); \
  AutoTokenizer.from_pretrained(model_name)"
```

### **2. Check Model Size First**

Before downloading, check model card on HuggingFace for:
- Model size (GB)
- Memory requirements
- Speed benchmarks

### **3. Use Quantization**

NanoLLM supports quantization for faster inference:
```bash
ros2 run jetbot_tools llm_chat_agent --ros-args \
  -p model:="meta-llama/Llama-2-7b-chat-hf" \
  -p quantization:="q4f16_ft"
```

### **4. Test Locally First**

Before using in robot, test model quality:
```python
from transformers import pipeline

pipe = pipeline("text-generation", 
                model="TinyLlama/TinyLlama-1.1B-Chat-v1.0")

result = pipe("Tell me about robots", max_new_tokens=100)
print(result[0]['generated_text'])
```

---

## 📋 Quick Reference

### **Get HuggingFace Token:**
1. Sign up: https://huggingface.co/join
2. Request model access (if gated)
3. Create token: https://huggingface.co/settings/tokens
4. Set environment: `export HUGGINGFACE_TOKEN="hf_..."`

### **Best Models (No Token Needed):**
- `TinyLlama/TinyLlama-1.1B-Chat-v1.0` - Fast & good
- `microsoft/Phi-3-mini-4k-instruct` - Best quality
- `stabilityai/stablelm-2-zephyr-1_6b` - Balanced

### **Premium Models (Token Needed):**
- `meta-llama/Llama-2-7b-chat-hf` - Excellent
- `meta-llama/Llama-3.2-3B-Instruct` - Latest
- `mistralai/Mistral-7B-Instruct-v0.2` - Top tier

### **Change Model:**
```bash
# Method 1: Parameter
ros2 run jetbot_tools llm_chat_agent --ros-args -p model:="MODEL_NAME"

# Method 2: Edit code (line 60 in llm_chat_agent.py)
self.llm_model = self.declare_parameter('model', 'MODEL_NAME')...
```

---

## 🎯 Recommended Next Step

**Start with TinyLlama (no token required):**

```bash
# 1. Inside container:
cd /ros2_ws && source install/setup.bash

# 2. Run with TinyLlama:
ros2 run jetbot_tools llm_chat_agent --ros-args \
  -p model:="TinyLlama/TinyLlama-1.1B-Chat-v1.0"

# 3. Test quality improvement!
```

**If you want Llama:**

```bash
# 1. Get token from https://huggingface.co/settings/tokens
# 2. Request access: https://huggingface.co/meta-llama/Llama-2-7b-chat-hf
# 3. Export token: export HUGGINGFACE_TOKEN="hf_..."
# 4. Run container and test
```

---

## 📚 Additional Resources

- **HuggingFace Model Hub**: https://huggingface.co/models
- **Llama Models**: https://huggingface.co/meta-llama
- **NanoLLM Documentation**: https://github.com/dusty-nv/NanoLLM
- **Token Management**: https://huggingface.co/docs/hub/security-tokens

---

**Status**: Ready to upgrade to better models! 🚀  
**Recommended First**: TinyLlama (no setup required)  
**For Best Quality**: Get HuggingFace token → Request Llama access → Enjoy! 🤖

---

*You can debug and optimize model selection later. The infrastructure is ready!* ✅


