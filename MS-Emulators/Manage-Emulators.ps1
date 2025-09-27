param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("help", "export", "import", "interactive", "start-azurite", "stop-azurite", "start-cosmos", "stop-cosmos")]
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
    Write-Host "  -Command    Command to execute (help, start-azurite, stop-azurite, start-cosmos, stop-cosmos)" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  help          Show this help message" -ForegroundColor White
    Write-Host "  check         Check if the specified container is running" -ForegroundColor White
    Write-Host "  start-azurite Start the Azurite storage emulator" -ForegroundColor White
    Write-Host "  stop-azurite  Stop the Azurite storage emulator" -ForegroundColor White
    Write-Host "  start-cosmos  Start the CosmosDB emulator" -ForegroundColor White
    Write-Host "  stop-cosmos   Stop the CosmosDB emulator" -ForegroundColor White
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

function Start-CosmosDb {
    Write-Host "Starting CosmosDB emulator..." -ForegroundColor Cyan
    
    # Check if container exists and is running
    $containerExists = docker ps -a --filter "name=cosmosdb-emulator" --format "{{.Names}}"
    $containerRunning = docker ps --filter "name=cosmosdb-emulator" --format "{{.Names}}"
    
    if ($containerRunning) {
        Write-Host "CosmosDB emulator is already running!" -ForegroundColor Green
        return
    }
    
    if ($containerExists) {
        Write-Host "Starting existing CosmosDB emulator container..." -ForegroundColor Yellow
        docker start cosmosdb-emulator
    } else {
        Write-Host "Creating and starting new CosmosDB emulator container..." -ForegroundColor Yellow
        docker-compose up -d cosmosdb-emulator
    }
    
    # Wait for the container to be healthy (CosmosDB emulator takes time to start)
    Write-Host "Waiting for CosmosDB emulator to be ready..." -ForegroundColor Yellow
    $maxAttempts = 30
    $attempt = 0
    $ready = $false
    
    do {
        $attempt++
        $status = docker ps --filter "name=cosmosdb-emulator" --format "{{.Status}}"
        if ($status -match "healthy") {
            $ready = $true
            break
        }
        Write-Host "Waiting for CosmosDB emulator to start (attempt $attempt of $maxAttempts)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    } while ($attempt -lt $maxAttempts)
    
    if ($ready) {
        Write-Host "CosmosDB emulator is now running!" -ForegroundColor Green
        Write-Host "Endpoint: https://localhost:8081" -ForegroundColor White
        Write-Host "Primary Key: C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==" -ForegroundColor White
    } else {
        Write-Host "Failed to start CosmosDB emulator or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-CosmosDb {
    Write-Host "Stopping CosmosDB emulator..." -ForegroundColor Cyan
    
    # Check if container is running
    $containerRunning = docker ps --filter "name=cosmosdb-emulator" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "CosmosDB emulator is not running!" -ForegroundColor Yellow
        return
    }
    
    # Stop the container
    docker stop cosmosdb-emulator
    
    # Verify the container is stopped
    $stillRunning = docker ps --filter "name=cosmosdb-emulator" --format "{{.Names}}"
    if (-not $stillRunning) {
        Write-Host "CosmosDB emulator has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop CosmosDB emulator!" -ForegroundColor Red
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
        "start-cosmos" {
            Start-CosmosDb
        }
        "stop-cosmos" {
            Stop-CosmosDb
        }
        default {
            Show-Help
        }
    }
}

# Run the main function with parsed parameters
Run-Main -command $Command