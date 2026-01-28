# Use specific version of nvidia cuda image
# FROM wlsdml1114/my-comfy-models:v1 as model_provider
FROM wlsdml1114/engui_genai-base_blackwell:1.1 as runtime

RUN pip install -U "huggingface_hub[hf_transfer]"
RUN pip install runpod websocket-client

WORKDIR /

RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
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
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo && \
    cd ComfyUI-LTXVideo && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes


#RUN wget -q https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-dev-fp8.safetensors -O /ComfyUI/models/checkpoints/ltx-2-19b-dev-fp8.safetensors
RUN wget -q https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp8_scaled.safetensors -O /ComfyUI/models/text_encoders/gemma_3_12B_it_fp8_scaled.safetensors
RUN wget -q https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/text_encoders/ltx-2-19b-embeddings_connector_dev_bf16.safetensors -O /ComfyUI/models/text_encoders/ltx-2-19b-embeddings_connector_dev_bf16.safetensors
RUN wget -q https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors -O /ComfyUI/models/latent_upscale_models/ltx-2-spatial-upscaler-x2-1.0.safetensors
RUN wget -q https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors -O /ComfyUI/models/loras/ltx-2-19b-distilled-lora-384.safetensors
RUN wget -q https://huggingface.co/Lightricks/LTX-2-19b-IC-LoRA-Detailer/resolve/main/ltx-2-19b-ic-lora-detailer.safetensors -O /ComfyUI/models/loras/ltx-2-19b-ic-lora-detailer.safetensors
RUN wget -q https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_audio_vae_bf16.safetensors -O /ComfyUI/models/vae/LTX2_audio_vae_bf16.safetensors
RUN wget -q https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_video_vae_bf16.safetensors -O /ComfyUI/models/vae/LTX2_video_vae_bf16.safetensors


# RUN wget -q https://huggingface.co/GitMylo/LTX-2-comfy_gemma_fp8_e4m3fn/resolve/main/gemma_3_12B_it_fp8_e4m3fn.safetensors -O /ComfyUI/models/text_encoders/gemma_3_12B_it_fp8_e4m3fn.safetensors
# RUN wget -q https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Left/resolve/main/ltx-2-19b-lora-camera-control-dolly-left.safetensors -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-dolly-left.safetensors


# RUN wget -q https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/diffusion_models/ltx-2-19b-dev_Q8_0.gguf -O /ComfyUI/models/diffusion_models/ltx-2-19b-dev_Q8_0.gguf
# RUN wget -q https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp8_scaled.safetensors -O /ComfyUI/models/text_encoders/gemma_3_12B_it_fp8_scaled.safetensors
# RUN wget -q https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/text_encoders/ltx-2-19b-embeddings_connector_dev_bf16.safetensors -O /ComfyUI/models/text_encoders/ltx-2-19b-embeddings_connector_dev_bf16.safetensors
# RUN wget -q https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_audio_vae_bf16.safetensors -O /ComfyUI/models/vae/LTX2_audio_vae_bf16.safetensors
# RUN wget -q https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_video_vae_bf16.safetensors -O /ComfyUI/models/vae/LTX2_video_vae_bf16.safetensors
# RUN wget -q https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors -O /ComfyUI/models/loras/ltx-2-19b-distilled-lora-384.safetensors
# RUN wget -q https://huggingface.co/Lightricks/LTX-2-19b-IC-LoRA-Detailer/resolve/main/ltx-2-19b-ic-lora-detailer.safetensors -O /ComfyUI/models/loras/ltx-2-19b-ic-lora-detailer.safetensors
# RUN wget -q https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors -O /ComfyUI/models/latent_upscale_models/ltx-2-spatial-upscaler-x2-1.0.safetensors


COPY . .
RUN mkdir -p /ComfyUI/user/default/ComfyUI-Manager
COPY config.ini /ComfyUI/user/default/ComfyUI-Manager/config.ini
COPY extra_model_paths.yaml /ComfyUI/extra_model_paths.yaml
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]