#!/bin/bash

# Start D-Bus (Required for Avahi to broadcast over mDNS)
mkdir -p /var/run/dbus
dbus-daemon --system

# Start Avahi Daemon (AirPrint discovery)
avahi-daemon -D

# Start AirSane in the background (eSCL scanning server)
airsaned &

# Start CUPS server in the foreground to keep the container running
exec /usr/sbin/cupsd -f