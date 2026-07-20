# === STAGE 1: Compile AirSane from source ===
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake git \
    libjpeg-dev libpng-dev libsane-dev \
    libavahi-client-dev libusb-1.0-0-dev

# Clone and build AirSane
RUN git clone https://github.com/SimulPiscator/AirSane.git /tmp/airsane && \
    cd /tmp/airsane && \
    mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# === STAGE 2: Final Image ===
FROM debian:bookworm-slim

# Install CUPS, HPLIP, Avahi (for AirPrint/mDNS), and SANE
RUN apt-get update && apt-get install -y --no-install-recommends \
    cups \
    cups-client \
    hplip \
    printer-driver-hpcups \
    avahi-daemon \
    libnss-mdns \
    dbus \
    sane \
    sane-utils \
    libjpeg62-turbo \
    libpng16-16 \
    libavahi-client3 \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled AirSane binaries from the builder stage
COPY --from=builder /usr/local/bin/airsaned /usr/local/bin/airsaned
#COPY --from=builder /usr/local/etc/airsane /etc/airsane

# Configure CUPS to allow remote network access
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow all/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow all/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow all/' /etc/cups/cupsd.conf

# Add the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports: 631 for CUPS, 8090 for AirSane
EXPOSE 631 8090

# Start the services
ENTRYPOINT ["/start.sh"]