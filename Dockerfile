FROM opencue/rqd

# Create the /opencue directory structure for logs and outputs
RUN mkdir -p /opencue/logs && \
    chmod -R 777 /opencue && \
    mkdir -p /home/opencue && \
    chmod -R 777 /home/opencue

# Set up the Cuebot connection environment variables (will be overridden at runtime)
ENV CUEBOT_HOSTNAME=opencue-cuebot
ENV CUEBOT_PORT=8443

# Entrypoint remains the same as the base image
ENTRYPOINT ["/bin/bash", "-c", "set -e && rqd"] 