#!/bin/bash
# GPU fan curve for NVIDIA 980 Ti (eGPU via Thunderbolt)
# Curve: 40% under 60C, linear ramp to 70% at 70C, holds 70% above that

DISPLAY=:0
UID_USER=1000

# Wait for XWayland socket to be ready
while ! [ -S /tmp/.X11-unix/X0 ]; do sleep 2; done

# Find the XWayland auth file (path changes each login)
get_xauth() {
    ls /run/user/${UID_USER}/xauth_* 2>/dev/null | head -1
}

export DISPLAY
export XAUTHORITY=$(get_xauth)

# Enable manual fan control
nvidia-settings -a "[gpu:0]/GPUFanControlState=1" > /dev/null 2>&1

while true; do
    # Refresh xauth in case session was restarted
    export XAUTHORITY=$(get_xauth)

    TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)

    if [ -z "$TEMP" ]; then
        sleep 5
        continue
    fi

    if [ "$TEMP" -lt 60 ]; then
        SPEED=40
    elif [ "$TEMP" -ge 70 ]; then
        SPEED=70
    else
        # Linear ramp: 3% per degree between 60C and 70C
        SPEED=$((40 + (TEMP - 60) * 3))
    fi

    nvidia-settings -a "[fan:0]/GPUTargetFanSpeed=${SPEED}" > /dev/null 2>&1

    sleep 5
done
