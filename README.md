# DIT-MicroRos

micro-ROS agent setup for **Eurobot 2026** — bridges microcontroller serial connections to a ROS 2 (Humble) network running inside Docker.

---

## Overview

This repository provides a Dockerized [micro-ROS agent](https://github.com/micro-ROS/micro_ros_agent) that exposes two serial-connected microcontrollers as ROS 2 nodes:

| Device | Baud Rate | Role |
|---|---|---|
| `/dev/mission` | 115200 | Mission controller |
| `/dev/chassis` | 2000000 | Chassis controller |

The container runs on the host network, so all ROS 2 topics/services are directly visible to every node on the same machine.

---

## Requirements

- Docker with [BuildKit](https://docs.docker.com/build/buildkit/) enabled
- Docker Compose v2
- Serial devices available at `/dev/mission` and `/dev/chassis` (create udev symlinks as needed)

---

## Repository Structure

```
.
├── docker/
│   ├── Dockerfile                  # ROS 2 Humble image with micro-ROS agent
│   ├── docker-compose.yaml         # Service definition
│   └── scripts/
│       └── install_micro_ros.sh    # Builds micro_ros_setup & agent inside the image
└── README.md
```

---

## Quick Start

### 1. Build the image

```bash
cd docker
docker compose build
```

### 2. Run the agent

```bash
docker compose up
```

On startup the container:
1. Sources ROS 2 Humble and the micro-ROS workspace.
2. Runs `colcon build` to ensure packages are up to date.
3. Launches two `micro_ros_agent` instances in parallel (one per serial device).

### 3. Stop the agent

```bash
docker compose down
```

---

## Configuration

Environment variables can be set in a `.env` file next to `docker-compose.yaml`:

| Variable | Default | Description |
|---|---|---|
| `USER_UID` | `1001` | UID for the container user |
| `USER_GID` | `1001` | GID for the container user |
| `ROS_DOMAIN_ID` | _(none)_ | ROS 2 domain ID |

Example `.env`:

```env
USER_UID=1000
USER_GID=1000
ROS_DOMAIN_ID=0
```

---

## Docker Image Details

| Property | Value |
|---|---|
| Base image | `ros:humble-ros-base-jammy` |
| RMW | `rmw_cyclonedds_cpp` |
| Container user | `micro-ros` |
| Timezone | `Asia/Taipei` |

The image is built for the host platform by default. Cross-compilation is supported via Docker BuildKit's `--platform` flag.

---

## Udev Rules (Recommended)

To get stable device names, add udev rules on the host:

```
# /etc/udev/rules.d/99-eurobot.rules
SUBSYSTEM=="tty", ATTRS{idVendor}=="XXXX", ATTRS{idProduct}=="YYYY", SYMLINK+="mission"
SUBSYSTEM=="tty", ATTRS{idVendor}=="AAAA", ATTRS{idProduct}=="BBBB", SYMLINK+="chassis"
```

Replace the vendor/product IDs with the actual values from `lsusb` or `udevadm info`.

Reload rules:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

---

## Team

**DIT Robotics** — Eurobot 2026
