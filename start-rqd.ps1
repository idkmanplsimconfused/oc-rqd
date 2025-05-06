# OpenCue RQD Client Setup Script for Windows
# Based on option 1 from https://www.opencue.io/docs/getting-started/deploying-rqd/

# Parse command line arguments
param (
    [string]$CuebotHostname = $env:CUEBOT_HOSTNAME,
    [string]$CuebotPort = "8443",
    [string]$RqdName = "rqd01",
    [string]$Network = "",
    [switch]$Build,
    [switch]$Help
)

# Display help if requested
if ($Help) {
    Write-Host "Usage: .\start-rqd.ps1 -CuebotHostname <hostname or IP> [-CuebotPort <port>] [-RqdName <container name>] [-Network <docker network>] [-Build] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -CuebotHostname   The hostname or IP address of the Cuebot server (required if the CUEBOT_HOSTNAME environment variable is not set)"
    Write-Host "                    - For same-machine containers: use 'opencue-cuebot' and specify the Network parameter"
    Write-Host "                    - For different machines: use the actual IP address or hostname"
    Write-Host "  -CuebotPort       The port to connect to on the Cuebot server (default: 8443)"
    Write-Host "  -RqdName          The name to give to the RQD container (default: rqd01)"
    Write-Host "  -Network          Docker network to connect RQD to (only needed if Cuebot is on same machine)"
    Write-Host "  -Build            Build the Docker image locally instead of pulling from DockerHub"
    Write-Host "  -Help             Display this help message"
    exit 0
}

# Check if CUEBOT_HOSTNAME is set in environment or via parameter
if (-not $CuebotHostname) {
    Write-Host "Error: Cuebot hostname not provided. Either:"
    Write-Host "  1. Set the CUEBOT_HOSTNAME environment variable, or"
    Write-Host "  2. Provide it as a parameter: .\start-rqd.ps1 -CuebotHostname <hostname or IP>"
    Write-Host ""
    Write-Host "Run .\start-rqd.ps1 -Help for more information."
    exit 1
}

# Set up the filesystem root for OpenCue
$CueFilesystemRoot = Join-Path $env:USERPROFILE "opencue-rqd"
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
if (-not [string]::IsNullOrEmpty($Network)) {
    Write-Host "Docker Network: $Network"
}
Write-Host "OpenCue Filesystem Root: $CueFilesystemRoot"
Write-Host "Build Local Image: $Build"
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

# Check if the specified Docker network exists if a network was provided
if (-not [string]::IsNullOrEmpty($Network)) {
    $networkExists = $false
    try {
        $networkInfo = docker network inspect $Network 2>&1
        if ($LASTEXITCODE -eq 0) {
            $networkExists = $true
        }
    } catch {
        # Network doesn't exist, which is a problem
    }

    if (-not $networkExists) {
        Write-Host "Error: Docker network '$Network' doesn't exist."
        Write-Host "Please make sure your Cuebot services are running first."
        Write-Host "Possible networks available:"
        docker network ls
        exit 1
    }
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

# Build the custom RQD image if requested
if ($Build) {
    Write-Host "Building custom RQD image from local Dockerfile..."
    docker build -t opencue/rqd ./
    $rqdImage = "opencue/rqd"
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
    # Create Docker volume mount string compatible with Windows
    $volumeMount = "$($CueFilesystemRoot -replace '\\', '/' -replace ':', ''):/opencue-rqd"
    
    # Build the Docker run command
    $dockerCmd = "docker run -td --name $RqdName " +
               "--env CUEBOT_HOSTNAME=$CuebotHostname " +
               "--env CUEBOT_PORT=$CuebotPort " +
               "--volume `"/$volumeMount`" "
    
    # Add network parameter if specified
    if (-not [string]::IsNullOrEmpty($Network)) {
        $dockerCmd += "--network $Network "
    }
    
    $dockerCmd += "$rqdImage"
    
    # Run the RQD container with proper settings
    Write-Host "Starting RQD container..."
    Write-Host "Command: $dockerCmd"
    Invoke-Expression $dockerCmd
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