FROM ghcr.io/m1k1o/neko/nvidia-xfce:latest

# This image has NVENC support for hardware-accelerated encoding
# Requires Nvidia GPU with NVENC (GTX 1050+ / RTX series)

USER root

# Install dependencies for Minecraft
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    software-properties-common \
    # Java 21 for Minecraft
    openjdk-21-jre \
    # Audio support
    pulseaudio \
    # OpenGL libraries
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libopenal1 \
    libgtk-3-0 \
    # Fonts
    fonts-dejavu \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /opt/minecraft /home/neko/.minecraft

# Download official Minecraft Launcher
RUN wget -O /tmp/minecraft-launcher.deb \
    "https://launcher.mojang.com/download/Minecraft.deb" && \
    dpkg -i /tmp/minecraft-launcher.deb || apt-get install -f -y && \
    rm /tmp/minecraft-launcher.deb

# Create desktop shortcut
RUN mkdir -p /home/neko/Desktop && \
    echo '[Desktop Entry]\n\
Type=Application\n\
Name=Minecraft\n\
Exec=minecraft-launcher\n\
Icon=minecraft-launcher\n\
Terminal=false\n\
Categories=Game;\n\
' > /home/neko/Desktop/minecraft.desktop && \
    chmod +x /home/neko/Desktop/minecraft.desktop

# Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Optimized JVM settings for GPU instance (more RAM available)
RUN echo '{\n\
  "profiles": {\n\
    "default": {\n\
      "name": "Cloud Gaming GPU",\n\
      "javaArgs": "-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"\n\
    }\n\
  }\n\
}' > /home/neko/.minecraft/launcher_profiles.json

# Fix permissions
RUN chown -R neko:neko /home/neko /opt/minecraft

USER neko
WORKDIR /home/neko
