# Abiotic Factor Dedicated Server (Docker)

<a href="README.zh-CN.md"><button>查看中文文档 / Read in Chinese</button></a>

## Repository layout
- `Dockerfile`: Builds the Ubuntu + WineHQ + SteamCMD runtime.
- `entrypoint.sh`: Installs/updates the server with SteamCMD and launches it via Wine.
- `docker-compose.yml`: Example deployment with volumes, ports, and environment variables.

## Prerequisites
- Docker Engine 24+ and Docker Compose V2.
- Enough disk space for the game files (the `gamefiles` directory) and save data (the `data` directory).

## Quick start
1. Clone this repository:
   ```bash
   git clone https://github.com/your-org/abiotic-factor-docker.git
   cd abiotic-factor-docker
   ```
2. Create the data folders (they are mounted by Docker Compose):
   ```bash
   mkdir -p gamefiles data
   ```
3. (Optional) Edit `docker-compose.yml` to adjust environment variables such as `ServerPassword`, `WorldSaveName`, or `AdditionalArgs`.
4. Start the server:
   ```bash
   docker compose up -d
   ```
5. Stop the server when needed:
   ```bash
   docker compose down
   ```

## Configuration reference
Key environment variables in `docker-compose.yml`:
- `MaxServerPlayers`: Maximum number of players (default: `6`).
- `Port` / `QueryPort`: UDP game and query ports (default: `7777` / `27015`).
- `ServerPassword`: Join password.
- `SteamServerName`: Name shown in the server browser.
- `WorldSaveName`: Save name used inside `data/`.
- `UsePerfThreads` / `NoAsyncLoadingThread`: Performance toggles (set to `false` to disable).
- `AutoUpdate`: Set to `true` to reinstall/update on every container start.
- `AdditionalArgs`: Extra launch arguments (e.g., sandbox ini path).

## Building and publishing the image
The GitHub Actions workflow builds and pushes the image to GHCR on every push and via a weekly schedule. By default, tags are published as:
- `ghcr.io/<owner>/<repo>:latest`
- `ghcr.io/<owner>/<repo>:<commit-sha>`

To use the published image locally after authenticating to GHCR:
```bash
docker pull ghcr.io/<owner>/<repo>:latest
docker compose up -d
```

To build manually without CI:
```bash
docker build -t ghcr.io/<owner>/<repo>:latest .
docker push ghcr.io/<owner>/<repo>:latest
```
Replace `<owner>/<repo>` with your GitHub namespace.

## Ports
The server exposes UDP `7777` (game) and UDP `27015` (query). Update the `ports` mapping in `docker-compose.yml` if you need different host ports.

## Updating the server
Set `AutoUpdate=true` in `docker-compose.yml` to download the latest dedicated server build each time the container starts. Otherwise, manually rebuild/redeploy the image when a new patch drops.
