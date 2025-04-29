# OpenCue RQD Client Stop Script for Windows

# Parse command line arguments
param (
    [string]$RqdName = "rqd01",
    [switch]$Help,
    [switch]$Remove
)

# Display help if requested
if ($Help) {
    Write-Host "Usage: .\stop-rqd.ps1 [-RqdName <RQD container name>] [-Remove] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -RqdName    The name of the RQD container to stop (default: rqd01)"
    Write-Host "  -Remove     Also remove the container after stopping"
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
    exit 0
}

# Check if the container is running
$containerRunning = docker ps -q -f "name=$RqdName"

if ($containerRunning) {
    Write-Host "Stopping RQD container '$RqdName'..."
    docker stop $RqdName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to stop RQD container."
        exit 1
    }
    
    Write-Host "RQD container stopped successfully."
} else {
    Write-Host "RQD container '$RqdName' is not running."
}

# Remove the container if requested
if ($Remove) {
    Write-Host "Removing RQD container '$RqdName'..."
    docker rm $RqdName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to remove RQD container."
        exit 1
    }
    
    Write-Host "RQD container removed successfully."
} 