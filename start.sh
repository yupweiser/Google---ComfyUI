#!/bin/bash

# 1. Start ComfyUI in the background on local port 8188
python3 /app/main.py --listen 127.0.0.1 --port 8188 --enable-manager --enable-manager-legacy-ui &

# 2. Start ttyd in the background on local port 7681 (with basic auth)
ttyd -p 7681 -c "admin:YourSecurePassword123" bash &

# 3. Run Nginx in the foreground on Cloud Run's required port 8080
nginx -g "daemon off;"
