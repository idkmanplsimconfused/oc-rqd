# OpenCue RQD Client Status Script for Windows

# Parse command line arguments
param (
    [string]$RqdName = "rqd01",
    [switch]$Help,
    [switch]$Logs,
    [int]$Lines = 25
)

# Display help if requested
if ($Help) {
    Write-Host "Usage: .\status-rqd.ps1 [-RqdName <RQD container name>] [-Logs] [-Lines <number>] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -RqdName    The name of the RQD container to check (default: rqd01)"
    Write-Host "  -Logs       Show container logs"
    Write-Host "  -Lines      Number of log lines to display (default: 25, used with -Logs)"
    Write-Host "  -Help       Display this help message"
    exit 0
}

# Check if the RQD container exists
$containerExists = $false
try {
    $containerInfo = docker container inspect $RqdName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $containerExists = $true
    }
} catch {
    # Container doesn't exist
}

if (-not $containerExists) {
    Write-Host "RQD container '$RqdName' does not exist."
    exit 1
}

# Check if the container is running
$containerRunning = docker ps -q -f "name=$RqdName"

if ($containerRunning) {
    Write-Host "RQD container '$RqdName' is RUNNING"
    
    # Show container details
    Write-Host ""
    Write-Host "Container Details:"
    Write-Host "=================="
    
    # Get container IP
    $containerIp = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $RqdName
    Write-Host "Container IP: $containerIp"
    
    # Get container creation time
    $creationTime = docker inspect -f '{{.Created}}' $RqdName
    Write-Host "Created: $creationTime"
    
    # Get container network
    $network = docker inspect -f '{{range $key, $value := .NetworkSettings.Networks}}{{$key}}{{end}}' $RqdName
    Write-Host "Network: $network"
    
    # Show port mappings if any
    $ports = docker inspect -f '{{range $port, $_ := .NetworkSettings.Ports}}{{$port}} {{end}}' $RqdName
    if ($ports) {
        Write-Host "Exposed Ports: $ports"
    } else {
        Write-Host "Exposed Ports: None"
    }
} else {
    Write-Host "RQD container '$RqdName' is NOT RUNNING"
}

# Show logs if requested
if ($Logs) {
    Write-Host ""
    Write-Host "Container Logs (last $Lines lines):"
    Write-Host "=================================="
    docker logs $RqdName --tail $Lines
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to retrieve container logs."
        exit 1
    }
} 