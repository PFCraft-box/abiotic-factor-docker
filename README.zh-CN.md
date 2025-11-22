# Abiotic Factor 专用服务器（Docker）

<a href="README.md"><button>Read the English version</button></a>


## 仓库结构
- `Dockerfile`：构建 Ubuntu + WineHQ + SteamCMD 运行环境。
- `entrypoint.sh`：使用 SteamCMD 安装/更新服务器并通过 Wine 启动。
- `docker-compose.yml`：包含卷、端口及环境变量的示例部署。

## 环境要求
- Docker Engine 24+ 与 Docker Compose V2。
- 为游戏文件（`gamefiles`）和存档数据（`data`）预留足够磁盘空间。

## 快速开始
1. 克隆仓库：
   ```bash
   git clone https://github.com/your-org/abiotic-factor-docker.git
   cd abiotic-factor-docker
   ```
2. 创建数据目录（Docker Compose 会挂载）：
   ```bash
   mkdir -p gamefiles data
   ```
3. （可选）编辑 `docker-compose.yml`，调整 `ServerPassword`、`WorldSaveName` 或 `AdditionalArgs` 等环境变量。
4. 启动服务器：
   ```bash
   docker compose up -d
   ```
5. 需要停止时：
   ```bash
   docker compose down
   ```

## 配置参考
`docker-compose.yml` 里的核心环境变量：
- `MaxServerPlayers`：最大玩家数（默认 `6`）。
- `Port` / `QueryPort`：UDP 游戏端口与查询端口（默认 `7777` / `27015`）。
- `ServerPassword`：加入服务器时的密码。
- `SteamServerName`：服务器列表显示名称。
- `WorldSaveName`：保存文件名，位于 `data/` 下。
- `UsePerfThreads` / `NoAsyncLoadingThread`：性能开关（设为 `false` 即关闭）。
- `AutoUpdate`：设为 `true` 时，容器启动会重新安装/更新服务器。
- `AdditionalArgs`：额外启动参数（如 Sandbox 配置路径）。

## 构建与发布镜像
GitHub Actions 工作流在每次提交与每周定期触发，默认发布以下标签：
- `ghcr.io/<owner>/<repo>:latest`
- `ghcr.io/<owner>/<repo>:<commit-sha>`

拉取已发布镜像并运行（需先登录 GHCR）：
```bash
docker pull ghcr.io/<owner>/<repo>:latest
docker compose up -d
```

若想手动构建发布：
```bash
docker build -t ghcr.io/<owner>/<repo>:latest .
docker push ghcr.io/<owner>/<repo>:latest
```
将 `<owner>/<repo>` 替换为你的 GitHub 命名空间。

## 端口说明
服务器开放 UDP `7777`（游戏）与 UDP `27015`（查询）；如需修改宿主机端口，请更新 `docker-compose.yml` 中的 `ports` 映射。

## 更新服务器
在 `docker-compose.yml` 将 `AutoUpdate` 设为 `true`，容器启动时会下载最新版本；否则请在新补丁发布后手动重新构建/部署镜像。
