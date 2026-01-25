# Use specific version of nvidia cuda image
# FROM wlsdml1114/my-comfy-models:v1 as model_provider
FROM wlsdml1114/multitalk-base:1.7 as runtime

RUN pip install -U "huggingface_hub[hf_transfer]"
RUN pip install runpod websocket-client

ARG CIVITAI_ACCESS_TOKEN

WORKDIR /

RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/city96/ComfyUI-GGUF && \
    cd ComfyUI-GGUF && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes && \
    cd ComfyUI-KJNodes && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    cd ComfyUI-VideoHelperSuite && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kael558/ComfyUI-GGUF-FantasyTalking && \
    cd ComfyUI-GGUF-FantasyTalking && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/orssorbit/ComfyUI-wanBlockswap

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper && \
    cd ComfyUI-WanVideoWrapper && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/rgthree/rgthree-comfy.git && \
    cd rgthree-comfy && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
    cd ComfyUI-Easy-Use && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/was-node-suite-comfyui.git && \
    cd was-node-suite-comfyui && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/PGCRT/CRT-Nodes.git && \
    cd CRT-Nodes && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/royceschultz/ComfyUI-Notifications.git && \
    git clone https://github.com/eddyhhlure1Eddy/IntelligentVRAMNode && \
    git clone https://github.com/eddyhhlure1Eddy/auto_wan2.2animate_freamtowindow_server && \
    git clone https://github.com/eddyhhlure1Eddy/ComfyUI-AdaptiveWindowSize && \
    cd ComfyUI-AdaptiveWindowSize/ComfyUI-AdaptiveWindowSize && \
    mv * ../

RUN wget -q "https://docs.google.com/uc?export=download&id=1piJLyhouuxK3m2DVvdFpTxEZbXb3SNKa" -o /ComfyUI/models/diffusion_models/DaSiWa_WAN_2_2_I2V_14B_LOW_fp8_e4m3fn_scaled.safetensors
RUN wget -q "https://docs.google.com/uc?export=download&id=1N2RzoqYSwOo_TUZ2EOTRUcHFn9AgNYAX" -o /ComfyUI/models/diffusion_models/Smooth_Mix_Wan_2_2_14B_HIGH_fp8_e4m3fn_scaled.safetensors


RUN wget -q "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" -o /ComfyUI/models/clip_vision/clip_vision_h.safetensors
RUN wget -q "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors" -o /ComfyUI/models/text_encoders/umt5-xxl-enc-bf16.safetensors
RUN wget -q "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors" -o /ComfyUI/models/vae/Wan2_1_VAE_bf16.safetensors


RUN wget -q "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors" -o /ComfyUI/models/loras/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors
RUN wget -q "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors" -o /ComfyUI/models/loras/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors

RUN wget -q "https://docs.google.com/uc?export=download&id=1Gkv5brhqrqMc9FMV5RWUAwbwR3mVI0nx" -o /ComfyUI/models/loras/WAN_3D_Face_high_low.safetensors
RUN wget -q "https://docs.google.com/uc?export=download&id=1m1rym9ivP9s_dxsDT64-sOBwmkM6tSdI" -o /ComfyUI/models/loras/Wan22-I2V-HIGH-Hip_Slammin_Assertive_Cowgirl.safetensors
RUN wget -q "https://docs.google.com/uc?export=download&id=1xX_jEgpaEnrD-QnfRfgS90sBIHrlMFyU" -o /ComfyUI/models/loras/Wan22-I2V-LOW-Hip_Slammin_Assertive_Cowgirl.safetensors


COPY . .
COPY extra_model_paths.yaml /ComfyUI/extra_model_paths.yaml
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]