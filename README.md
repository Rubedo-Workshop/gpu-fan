# gpu-fan

Temperature-based fan curve daemon for NVIDIA GPUs on Linux (Wayland).

Built for a GTX 980 Ti running as a Thunderbolt eGPU on a Mac Mini 2018 with KDE Plasma (Wayland). Works around the lack of NV-CONTROL X11 support on Wayland by connecting to the XWayland socket directly.

## Requirements

- NVIDIA GPU with proprietary driver
- `nvidia-settings` installed
- XWayland running (standard on KDE/GNOME Wayland sessions)
- Run as root (system service)

## Install

```bash
sudo cp gpu-fan.sh /usr/local/bin/gpu-fan.sh
sudo chmod +x /usr/local/bin/gpu-fan.sh
sudo cp gpu-fan.service /etc/systemd/system/gpu-fan.service
sudo systemctl daemon-reload
sudo systemctl enable --now gpu-fan
```

## Fan curve

| GPU Temp | Fan Speed |
|----------|-----------|
| < 60°C | 40% (quiet idle) |
| 60–70°C | Linear ramp (3% per degree) |
| ≥ 70°C | 70% (gaming cap) |

Edit `gpu-fan.sh` to adjust the curve to your preference.

## How it works

Tools like GreenWithEnvy and nvidia-settings require the NV-CONTROL X11 extension, which is unavailable under Wayland. However, XWayland runs alongside most Wayland compositors and exposes an X11 socket that NV-CONTROL can reach.

The daemon:
1. Waits for the XWayland socket (`/tmp/.X11-unix/X0`) to be ready at boot
2. Finds the XWayland auth file dynamically (`/run/user/1000/xauth_*`) since it changes each login
3. Enables manual fan control via `nvidia-settings`
4. Polls GPU temperature every 5 seconds via `nvidia-smi` and sets fan speed accordingly

## Verify it's working

```bash
systemctl status gpu-fan
nvidia-smi --query-gpu=fan.speed,temperature.gpu --format=csv
```
