#!/bin/bash
# start_agents.sh — Launch mission & chassis micro-ROS agents in a tmux session.

set -e

# Source ROS 2 and micro-ROS workspace
source /opt/ros/humble/setup.bash
source ~/micro_ros_ws/install/setup.bash

SESSION_NAME="micro-ros"

# Mission agent command
MISSION_CMD="source /opt/ros/humble/setup.bash && source ~/micro_ros_ws/install/setup.bash && ros2 run micro_ros_agent micro_ros_agent serial -b 115200 -D /dev/mission"

# Chassis agent command
CHASSIS_CMD="source /opt/ros/humble/setup.bash && source ~/micro_ros_ws/install/setup.bash && ros2 run micro_ros_agent micro_ros_agent serial -b 2000000 -D /dev/chassis"

# Create a new tmux session (detached) running the mission agent
tmux new-session -d -s "$SESSION_NAME" -n agents "$MISSION_CMD"

# Split the window horizontally and run the chassis agent
tmux split-window -v -t "$SESSION_NAME" "$CHASSIS_CMD"

# Attach to the session (keeps the container alive)
exec tmux attach -t "$SESSION_NAME"
