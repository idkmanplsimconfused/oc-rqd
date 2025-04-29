# OpenCue RQD Client

This directory contains scripts for setting up and managing RQD (OpenCue Render Queue Daemon) clients using Docker on Windows and Linux.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- For Windows: PowerShell 7.0 or newer
- For Linux: Bash shell
- A running OpenCue Cuebot server (from the `cuebot-server` directory)

## Setup

The RQD client connects to the Cuebot server, which manages the render queue. Before starting RQD, you need to know the hostname or IP address of your Cuebot server.

## Windows Scripts

### start-rqd.ps1

Starts an RQD client using the pre-built Docker image from DockerHub.

```powershell
.\start-rqd.ps1 -CuebotHostname <hostname or IP> [-CuebotPort <port>] [-RqdName <container name>]
```

Options:
- `-CuebotHostname`: The hostname or IP address of the Cuebot server (required if the CUEBOT_HOSTNAME environment variable is not set)
- `-CuebotPort`: The port to connect to on the Cuebot server (default: 8443)
- `-RqdName`: The name to give to the RQD container (default: rqd01)
- `-Help`: Display help message

Example:
```powershell
.\start-rqd.ps1 -CuebotHostname localhost
.\start-rqd.ps1 -CuebotHostname localhost -CuebotPort 8080
```

### stop-rqd.ps1

Stops a running RQD container.

```powershell
.\stop-rqd.ps1 [-RqdName <container name>] [-Remove]
```

Options:
- `-RqdName`: The name of the RQD container to stop (default: rqd01)
- `-Remove`: Also remove the container after stopping
- `-Help`: Display help message

### status-rqd.ps1

Checks the status of an RQD container and optionally displays its logs.

```powershell
.\status-rqd.ps1 [-RqdName <container name>] [-Logs] [-Lines <number>]
```

Options:
- `-RqdName`: The name of the RQD container to check (default: rqd01)
- `-Logs`: Show container logs
- `-Lines`: Number of log lines to display (default: 25, used with -Logs)
- `-Help`: Display help message

## Linux Scripts

### start-rqd.sh

Starts an RQD client using the pre-built Docker image from DockerHub.

```bash
./start-rqd.sh -c <hostname or IP> [-p <port>] [-n <container name>]
```

Options:
- `-c, --cuebot-hostname`: The hostname or IP address of the Cuebot server
- `-p, --cuebot-port`: The port to connect to on the Cuebot server (default: 8443)
- `-n, --name`: The name to give to the RQD container (default: rqd01)
- `-h, --help`: Display help message

Example:
```bash
./start-rqd.sh -c localhost
./start-rqd.sh -c localhost -p 8080
```

### stop-rqd.sh

Stops a running RQD container.

```bash
./stop-rqd.sh [-n <container name>] [-r]
```

Options:
- `-n, --name`: The name of the RQD container to stop (default: rqd01)
- `-r, --remove`: Also remove the container after stopping
- `-h, --help`: Display help message

Example:
```bash
./stop-rqd.sh
./stop-rqd.sh -r
```

### status-rqd.sh

Checks the status of an RQD container and optionally displays its logs.

```bash
./status-rqd.sh [-n <container name>] [-l] [-t <number>]
```

Options:
- `-n, --name`: The name of the RQD container to check (default: rqd01)
- `-l, --logs`: Show container logs
- `-t, --tail`: Number of log lines to display (default: 25, used with --logs)
- `-h, --help`: Display help message

Example:
```bash
./status-rqd.sh
./status-rqd.sh -l -t 50
```

## Managing Multiple RQD Clients

You can run multiple RQD clients on the same machine by specifying different container names:

**Windows:**
```powershell
.\start-rqd.ps1 -CuebotHostname localhost -RqdName rqd01
.\start-rqd.ps1 -CuebotHostname localhost -RqdName rqd02
```

**Linux:**
```bash
./start-rqd.sh -c localhost -n rqd01
./start-rqd.sh -c localhost -n rqd02
```

## File System Access

The RQD container needs access to the filesystem where render assets are stored and log files are written. 

- On Windows, it mounts the `%USERPROFILE%\opencue-demo` directory
- On Linux, it mounts the `$HOME/opencue-demo` directory

These directories are created if they don't exist.

## Connecting to Cuebot

The RQD client needs to know how to connect to the Cuebot server. By default, it will connect to the Cuebot server at the specified hostname using port 8443 (HTTPS). If your Cuebot server is configured to use a different port, you can specify it using the `-CuebotPort` (Windows) or `-p`/`--cuebot-port` (Linux) parameter.

For example, to connect to a Cuebot server running on port 8080 (HTTP):

**Windows:**
```powershell
.\start-rqd.ps1 -CuebotHostname localhost -CuebotPort 8080
```

**Linux:**
```bash
./start-rqd.sh -c localhost -p 8080
```

## Logs and Debugging

To check the logs of an RQD container:

**Windows:**
```powershell
.\status-rqd.ps1 -Logs
# or directly with Docker
docker logs rqd01
```

**Linux:**
```bash
./status-rqd.sh -l
# or directly with Docker
docker logs rqd01
```

## Windows Command Prompt Support

The repository also includes `.bat` files for users who prefer to use Windows Command Prompt instead of PowerShell.

## References

For more information about OpenCue RQD, see the [official documentation](https://www.opencue.io/docs/getting-started/deploying-rqd/). 