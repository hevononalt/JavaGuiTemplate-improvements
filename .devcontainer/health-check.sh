#!/bin/bash
set -e

echo "🔍 Checking noVNC services..."

max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if ss -ltn 2>/dev/null | grep -q ':6080'; then
        echo "✅ noVNC is listening on port 6080"
        break
    fi
    
    attempt=$((attempt + 1))
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ ERROR: noVNC failed to start. Check logs:"
        echo ""
        echo "--- supervisord log ---"
        cat /var/supervisor/supervisord.log 2>/dev/null || echo "No log available"
        echo ""
        echo "--- x11vnc log ---"
        cat /var/supervisor/x11vnc.log 2>/dev/null || echo "No log available"
        exit 1
    fi
    
    sleep 1
done

# Check individual services
echo "🔍 Checking individual services..."
services=("xvfb" "fluxbox" "x11vnc" "novnc")

for service in "${services[@]}"; do
    if pgrep -f "$service" > /dev/null; then
        echo "✅ $service is running"
    else
        echo "⚠️  WARNING: $service may not be running"
    fi
done

echo ""
echo "🎉 All systems ready! Desktop is available on port 6080"
echo "Password: vscode"
