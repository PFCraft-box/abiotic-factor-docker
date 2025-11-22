FROM ubuntu:24.04

# 非交互模式
ENV DEBIAN_FRONTEND=noninteractive

# 安装 WineHQ 官方源 + Wine 稳定版 + steamcmd（headless）
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget \
        software-properties-common && \
    \
    # 启用 multiverse 以安装 steamcmd
    add-apt-repository -y multiverse && \
    \
    # WineHQ 官方 key & 源（Ubuntu 24.04 = noble）
    mkdir -p /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ \
      https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources && \
    \
    apt-get update && \
    # WineHQ 官方建议使用 --install-recommends 安装 winehq-stable
    apt-get install -y --install-recommends winehq-stable && \
    \
    # 预先接受 steam 许可，避免构建时卡住
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends steamcmd && \
    \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# SteamCMD 在 /usr/games
ENV PATH="/usr/games:${PATH}"

# 纯 64 位 Wine，禁用多余 debug，避免 gecko/mono 弹窗
ENV WINEDEBUG=-all \
    WINEARCH=win64 \
    WINEPREFIX=/server/.wine \
    WINEDLLOVERRIDES="mscoree,mshtml="

# 游戏安装目录
WORKDIR /server

# 拷贝启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
