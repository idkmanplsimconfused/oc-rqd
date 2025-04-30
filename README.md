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
.\start-rqd.ps1 -CuebotHostname <hostname or IP> [-CuebotPort <port>] [-RqdName <container name>] [-Network <docker network>]
```

Options:
- `-CuebotHostname`: The hostname or IP address of the Cuebot server (required if the CUEBOT_HOSTNAME environment variable is not set)
  - For same-machine containers: use 'opencue-cuebot' and specify the Network parameter
  - For different machines: use the actual IP address or hostname
- `-CuebotPort`: The port to connect to on the Cuebot server (default: 8443)
- `-RqdName`: The name to give to the RQD container (default: rqd01)
- `-Network`: Docker network to connect RQD to (only needed if Cuebot is on same machine)
- `-Help`: Display help message

Examples:
```powershell
# When Cuebot is on the same machine (running in Docker)
.\start-rqd.ps1 -CuebotHostname opencue-cuebot -Network cuebot-server_opencue-network

# When Cuebot is on a different machine
.\start-rqd.ps1 -CuebotHostname 192.168.1.100
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
./start-rqd.sh -c <hostname or IP> [-p <port>] [-n <container name>] [-w <network>]
```

Options:
- `-c, --cuebot-hostname`: The hostname or IP address of the Cuebot server
  - For same-machine containers: use 'opencue-cuebot' and specify the network
  - For different machines: use the actual IP address or hostname
- `-p, --cuebot-port`: The port to connect to on the Cuebot server (default: 8443)
- `-n, --name`: The name to give to the RQD container (default: rqd01)
- `-w, --network`: Docker network to connect RQD to (only needed if Cuebot is on same machine)
- `-h, --help`: Display help message

Examples:
```bash
# When Cuebot is on the same machine (running in Docker)
./start-rqd.sh -c opencue-cuebot -w cuebot-server_opencue-network

# When Cuebot is on a different machine
./start-rqd.sh -c 192.168.1.100
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
.\start-rqd.ps1 -CuebotHostname opencue-cuebot -Network cuebot-server_opencue-network -RqdName rqd01
.\start-rqd.ps1 -CuebotHostname opencue-cuebot -Network cuebot-server_opencue-network -RqdName rqd02
```

**Linux:**
```bash
./start-rqd.sh -c opencue-cuebot -w cuebot-server_opencue-network -n rqd01
./start-rqd.sh -c opencue-cuebot -w cuebot-server_opencue-network -n rqd02
```

## File System Access

The RQD container needs access to the filesystem where render assets are stored and log files are written. 

- On Windows, it mounts the `%USERPROFILE%\opencue-demo` directory
- On Linux, it mounts the `$HOME/opencue-demo` directory

These directories are created if they don't exist.

## Connecting to Cuebot

### Same Machine Setup

If Cuebot is running on the same machine as RQD (both in Docker containers):

1. You need to connect them to the same Docker network
2. Use the container name as the hostname

**Windows:**
```powershell
.\start-rqd.ps1 -CuebotHostname opencue-cuebot -Network cuebot-server_opencue-network
```

**Linux:**
```bash
./start-rqd.sh -c opencue-cuebot -w cuebot-server_opencue-network
```

### Different Machine Setup

If Cuebot is running on a different machine:

1. Use the IP address or hostname of the remote machine
2. Ensure the Cuebot port (default: 8443) is accessible from the RQD machine

**Windows:**
```powershell
.\start-rqd.ps1 -CuebotHostname 192.168.1.100
```

**Linux:**
```bash
./start-rqd.sh -c 192.168.1.100
```

### Custom Port Configuration

If your Cuebot server is configured to use a different port, you can specify it:

**Windows:**
```powershell
.\start-rqd.ps1 -CuebotHostname opencue-cuebot -Network cuebot-server_opencue-network -CuebotPort 8080
```

**Linux:**
```bash
./start-rqd.sh -c opencue-cuebot -w cuebot-server_opencue-network -p 8080
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