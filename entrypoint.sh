#!/usr/bin/env bash
set -euo pipefail

# --------- 环境变量默认值（可在 docker-compose 里覆盖） ---------
MaxServerPlayers="${MaxServerPlayers:-6}"
Port="${Port:-7777}"
QueryPort="${QueryPort:-27015}"
ServerPassword="${ServerPassword:-password}"
SteamServerName="${SteamServerName:-LinuxServer}"
WorldSaveName="${WorldSaveName:-Cascade}"
AdditionalArgs="${AdditionalArgs:-}"

# 是否在容器启动时自动更新 / 首次安装
AutoUpdate="${AutoUpdate:-false}"

# 优化参数开关（原仓库里也用到）:contentReference[oaicite:3]{index=3}
UsePerfThreads="${UsePerfThreads:-true}"
NoAsyncLoadingThread="${NoAsyncLoadingThread:-true}"

SetUsePerfThreads="-useperfthreads "
if [[ "${UsePerfThreads,,}" == "false" ]]; then
  SetUsePerfThreads=""
fi

SetNoAsyncLoadingThread="-NoAsyncLoadingThread "
if [[ "${NoAsyncLoadingThread,,}" == "false" ]]; then
  SetNoAsyncLoadingThread=""
fi

# --------- 初始化 Wine 前缀（纯命令行，无图形） ---------
# 使用 Dockerfile 里设置的 WINEPREFIX/WINEARCH
export WINEPREFIX="${WINEPREFIX:-/server/.wine}"
export WINEARCH="${WINEARCH:-win64}"
export WINEDEBUG="${WINEDEBUG:--all}"
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-mscoree,mshtml=}"

if [ ! -d "${WINEPREFIX}" ]; then
  echo "[entrypoint] Initializing Wine prefix at ${WINEPREFIX} (win64)…"
  # wineboot 在无 X 环境下也能初始化前缀；失败不致命
  wineboot --init || true
fi

# --------- 使用 SteamCMD 安装 / 更新 Abiotic Factor 专用服 ---------
# AppID 2857200 为 Abiotic Factor Dedicated Server:contentReference[oaicite:4]{index=4}
if [ ! -d "/server/AbioticFactor/Binaries/Win64" ] || [[ "${AutoUpdate,,}" == "true" ]]; then
  echo "[entrypoint] Installing / updating Abiotic Factor dedicated server via SteamCMD…"
  steamcmd \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /server \
    +login anonymous \
    +app_update 2857200 validate \
    +quit
fi

SERVER_DIR="/server/AbioticFactor/Binaries/Win64"

if [ ! -x "${SERVER_DIR}/AbioticFactorServer-Win64-Shipping.exe" ]; then
  echo "[entrypoint] ERROR: Server binary not found at ${SERVER_DIR}/AbioticFactorServer-Win64-Shipping.exe"
  exit 1
fi

cd "${SERVER_DIR}"

echo "[entrypoint] Starting Abiotic Factor dedicated server with Wine (headless)…"

# 使用 exec 让容器正确接收信号（方便 docker stop）
exec wine AbioticFactorServer-Win64-Shipping.exe \
  ${SetUsePerfThreads}${SetNoAsyncLoadingThread}-MaxServerPlayers="${MaxServerPlayers}" \
  -PORT="${Port}" \
  -QueryPort="${QueryPort}" \
  -ServerPassword="${ServerPassword}" \
  -SteamServerName="${SteamServerName}" \
  -WorldSaveName="${WorldSaveName}" \
  -tcp \
  ${AdditionalArgs}
