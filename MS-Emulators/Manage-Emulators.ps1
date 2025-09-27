param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("help", "check", "stop", "export", "import", "interactive", "start-azurite", "stop-azurite")]
    [string]$Command = "help")

# Example aliases
Set-Alias k kubectl

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "Docker is installed and the command is available."
} else {
    Write-Host "Docker is NOT installed."
    Set-Alias docker podman
}

function Show-Help {
    $sriptName =".\Manage-Emulators.ps1"
    Write-Host "Emulators Manager Script" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: $sriptName -Command <command>" -ForegroundColor White
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -Command    Command to execute (help, check, start-azurite, stop-azurite)" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  help          Show this help message" -ForegroundColor White
    Write-Host "  check         Check if the specified container is running" -ForegroundColor White
    Write-Host "  start-azurite Start the Azurite storage emulator" -ForegroundColor White
    Write-Host "  stop-azurite  Stop the Azurite storage emulator" -ForegroundColor White
}

function Start-Azurite {
    Write-Host "Starting Azurite storage emulator..." -ForegroundColor Cyan
    
    # Check if container exists and is running
    $containerExists = docker ps -a --filter "name=azurite" --format "{{.Names}}"
    $containerRunning = docker ps --filter "name=azurite" --format "{{.Names}}"
    
    if ($containerRunning) {
        Write-Host "Azurite is already running!" -ForegroundColor Green
        return
    }
    
    if ($containerExists) {
        Write-Host "Starting existing Azurite container..." -ForegroundColor Yellow
        docker start azurite
    } else {
        Write-Host "Creating and starting new Azurite container..." -ForegroundColor Yellow
        # Create azurite directory if it doesn't exist
        if (-not (Test-Path ".\azurite")) {
            New-Item -ItemType Directory -Path ".\azurite"
        }
        
        docker-compose up -d azurite
    }
    
    # Verify the container is running
    $running = docker ps --filter "name=azurite" --format "{{.Names}}"
    if ($running) {
        Write-Host "Azurite is now running!" -ForegroundColor Green
        Write-Host "Blob storage endpoint: http://127.0.0.1:10000" -ForegroundColor White
        Write-Host "Queue storage endpoint: http://127.0.0.1:10001" -ForegroundColor White
        Write-Host "Table storage endpoint: http://127.0.0.1:10002" -ForegroundColor White
    } else {
        Write-Host "Failed to start Azurite!" -ForegroundColor Red
    }
}

function Stop-Azurite {
    Write-Host "Stopping Azurite storage emulator..." -ForegroundColor Cyan
    
    # Check if container is running
    $containerRunning = docker ps --filter "name=azurite" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "Azurite is not running!" -ForegroundColor Yellow
        return
    }
    
    # Stop the container
    docker stop azurite
    
    # Verify the container is stopped
    $stillRunning = docker ps --filter "name=azurite" --format "{{.Names}}"
    if (-not $stillRunning) {
        Write-Host "Azurite has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop Azurite!" -ForegroundColor Red
    }
}

function Run-Main(){
    param([string]$command,  [string]$name, [string]$distro, [string]$filePath, [string]$installLocation )
    # Main script logic
    switch ($command) {
        "help" {
            Show-Help
        }
        "start-azurite" {
            Start-Azurite
        }
        "stop-azurite" {
            Stop-Azurite
        }
        default {
            Show-Help
        }
    }
}

# Run the main function with parsed parameters
Run-Main -command $Command