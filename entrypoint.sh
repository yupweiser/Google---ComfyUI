#!/bin/bash

# Sync custom nodes from your GCS bucket to the local container directory on boot
echo "Syncing custom nodes from GCS bucket..."
mkdir -p /app/custom_nodes
gcloud storage cp -r gs://yupweiser-comfyui-models/custom_nodes/* /app/custom_nodes/

# Start ComfyUI
exec python3 main.py --listen 0.0.0.0 --port ${PORT:-8080}
