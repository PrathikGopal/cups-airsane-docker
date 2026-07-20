#!/bin/bash

# Remove stale PID files that might block services from starting
rm -f /var/run/dbus/pid
rm -f /var/run/avahi-daemon/pid

# Start D-Bus
mkdir -p /var/run/dbus
dbus-daemon --system

# Start Avahi Daemon
avahi-daemon -D

# Start AirSane in the background
airsaned &

# Start CUPS server in the foreground
exec /usr/sbin/cupsd -f