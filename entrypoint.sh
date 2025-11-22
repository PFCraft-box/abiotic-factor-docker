#!/usr/bin/env bash
set -euo pipefail

# --------- 环境变量默认值（可在 docker-compose 里覆盖） / Default env values (overridable in docker-compose) ---------
MaxServerPlayers="${MaxServerPlayers:-6}"
Port="${Port:-7777}"
QueryPort="${QueryPort:-27015}"
ServerPassword="${ServerPassword:-password}"
SteamServerName="${SteamServerName:-LinuxServer}"
WorldSaveName="${WorldSaveName:-Cascade}"
AdditionalArgs="${AdditionalArgs:-}"

# 是否在容器启动时自动更新 / 首次安装 / Auto-update or install on container start
AutoUpdate="${AutoUpdate:-false}"

# 优化参数开关（原仓库里也用到） / Performance tuning switches (also used in the original repository)
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

# --------- 初始化 Wine 前缀（纯命令行，无图形） / Initialize Wine prefix (CLI only, no GUI) ---------
# 使用 Dockerfile 里设置的 WINEPREFIX/WINEARCH / Use WINEPREFIX/WINEARCH configured in Dockerfile
export WINEPREFIX="${WINEPREFIX:-/server/.wine}"
export WINEARCH="${WINEARCH:-win64}"
export WINEDEBUG="${WINEDEBUG:--all}"
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-mscoree,mshtml=}"

if [ ! -d "${WINEPREFIX}" ]; then
  echo "[entrypoint] Initializing Wine prefix at ${WINEPREFIX} (win64)…"
  wineboot --init || true
fi

# --------- 使用 SteamCMD 安装 / 更新 Abiotic Factor / Install or update Abiotic Factor dedicated server via SteamCMD ---------
# AppID 2857200 为 Abiotic Factor Dedicated Server / AppID 2857200 corresponds to Abiotic Factor Dedicated Server
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

# 使用 exec 让容器正确接收信号（方便 docker stop） / Use exec so the container receives signals properly (helps docker stop)
exec wine AbioticFactorServer-Win64-Shipping.exe \
  ${SetUsePerfThreads}${SetNoAsyncLoadingThread}-MaxServerPlayers="${MaxServerPlayers}" \
  -PORT="${Port}" \
  -QueryPort="${QueryPort}" \
  -ServerPassword="${ServerPassword}" \
  -SteamServerName="${SteamServerName}" \
  -WorldSaveName="${WorldSaveName}" \
  -tcp \
  ${AdditionalArgs}
