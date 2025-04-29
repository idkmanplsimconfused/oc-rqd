# OpenCue RQD Client Setup Script for Windows
# Based on option 1 from https://www.opencue.io/docs/getting-started/deploying-rqd/

# Parse command line arguments
param (
    [string]$CuebotHostname = "",
    [string]$CuebotPort = "8443",
    [string]$RqdName = "rqd01",
    [switch]$Help
)

# Display help if requested
if ($Help) {
    Write-Host "Usage: .\start-rqd.ps1 [-CuebotHostname <hostname or IP>] [-CuebotPort <port>] [-RqdName <RQD container name>] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -CuebotHostname    The hostname or IP address of the Cuebot server (required if CUEBOT_HOSTNAME env var not set)"
    Write-Host "  -CuebotPort        The port to connect to on the Cuebot server (default: 8443)"
    Write-Host "  -RqdName           The name to give to the RQD container (default: rqd01)"
    Write-Host "  -Help              Display this help message"
    exit 0
}

# Check if CUEBOT_HOSTNAME is set in environment or via parameter
if ([string]::IsNullOrEmpty($CuebotHostname)) {
    $CuebotHostname = $env:CUEBOT_HOSTNAME
    if ([string]::IsNullOrEmpty($CuebotHostname)) {
        Write-Host "Error: Cuebot hostname not provided. Either:"
        Write-Host "  1. Set the CUEBOT_HOSTNAME environment variable, or"
        Write-Host "  2. Provide it as a parameter: .\start-rqd.ps1 -CuebotHostname <hostname or IP>"
        Write-Host ""
        Write-Host "Run .\start-rqd.ps1 -Help for more information."
        exit 1
    }
}

# Set up the filesystem root for OpenCue
$CueFilesystemRoot = Join-Path $env:USERPROFILE "opencue-demo"
if (-not (Test-Path $CueFilesystemRoot)) {
    Write-Host "Creating OpenCue filesystem root directory at $CueFilesystemRoot..."
    New-Item -ItemType Directory -Path $CueFilesystemRoot | Out-Null
}

# Set environment variables
$env:CUEBOT_HOSTNAME = $CuebotHostname
$env:CUEBOT_PORT = $CuebotPort
$env:CUE_FS_ROOT = $CueFilesystemRoot

Write-Host "RQD Configuration Summary:"
Write-Host "=========================="
Write-Host "Cuebot Hostname: $CuebotHostname"
Write-Host "Cuebot Port: $CuebotPort"
Write-Host "RQD Container Name: $RqdName"
Write-Host "OpenCue Filesystem Root: $CueFilesystemRoot"
Write-Host ""

# Check if Docker is installed and running
try {
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not running"
    }
} catch {
    Write-Host "Error: Docker is not installed or not running."
    Write-Host "Please install Docker Desktop for Windows and start it before running this script."
    exit 1
}

# Check if the RQD container already exists
$containerExists = $false
try {
    $containerInfo = docker container inspect $RqdName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $containerExists = $true
    }
} catch {
    # Container doesn't exist, which is fine
}

if ($containerExists) {
    Write-Host "RQD container '$RqdName' already exists."
    
    # Check if the container is running
    $containerRunning = docker ps -q -f "name=$RqdName"
    
    if ($containerRunning) {
        Write-Host "RQD container is already running."
    } else {
        Write-Host "Starting existing RQD container..."
        docker start $RqdName
    }
} else {
    # Pull the RQD image from DockerHub
    Write-Host "Pulling RQD image from DockerHub..."
    docker pull opencue/rqd
    
    # Run the RQD container
    Write-Host "Starting RQD container..."
    docker run -td --name $RqdName `
        --env CUEBOT_HOSTNAME=$CuebotHostname `
        --env CUEBOT_PORT=$CuebotPort `
        --volume "${CueFilesystemRoot}:${CueFilesystemRoot}" `
        opencue/rqd
}

# Verify the container is running
$containerRunning = docker ps -q -f "name=$RqdName"
if ($containerRunning) {
    Write-Host "RQD container is now running."
    
    # Display the logs
    Write-Host "RQD container logs:"
    Write-Host "=================="
    docker logs $RqdName --tail 20
} else {
    Write-Host "Error: Failed to start RQD container."
    Write-Host "Check Docker logs for more information:"
    Write-Host "docker logs $RqdName"
    exit 1
}

Write-Host ""
Write-Host "RQD setup complete!"
Write-Host "To stop RQD, run: docker stop $RqdName"
Write-Host "To view RQD logs, run: docker logs $RqdName" 