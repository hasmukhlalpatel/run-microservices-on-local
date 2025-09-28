param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("help", "export", "import", "interactive", 
                "start-azurite", "stop-azurite", 
                "start-cosmos", "stop-cosmos",
                "start-mssql", "stop-mssql",
                "start-sqledge", "stop-sqledge",
                "start-servicebus", "stop-servicebus")]
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
    Write-Host "  -Command    Command to execute" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  help              Show this help message" -ForegroundColor White
    Write-Host "  start-azurite     Start the Azurite storage emulator" -ForegroundColor White
    Write-Host "  stop-azurite      Stop the Azurite storage emulator" -ForegroundColor White
    Write-Host "  start-cosmos      Start the CosmosDB emulator" -ForegroundColor White
    Write-Host "  stop-cosmos       Stop the CosmosDB emulator" -ForegroundColor White
    Write-Host "  start-mssql       Start the MSSQL server" -ForegroundColor White
    Write-Host "  stop-mssql        Stop the MSSQL server" -ForegroundColor White
    Write-Host "  start-sqledge     Start the SQL Edge server" -ForegroundColor White
    Write-Host "  stop-sqledge      Stop the SQL Edge server" -ForegroundColor White
    Write-Host "  start-servicebus  Start the Service Bus emulator" -ForegroundColor White
    Write-Host "  stop-servicebus   Stop the Service Bus emulator" -ForegroundColor White
}

$Azurite = "azurite"
$CosmosDb = "cosmosdb-emulator"
$MsSql = "mssql"
$SqlEdge = "sqledge"
$ServiceBus = "servicebus-emulator"

function Check-ContainerExists([string]$name) {
    $container = docker ps -a --filter "name=$name" --format "{{.Names}}"
    if ($LASTEXITCODE -eq 0) {
        return -not [string]::IsNullOrEmpty($container)
    } else {
        Write-Host "✗ Docker command for Container '$Name failed with exit code $LASTEXITCODE." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

function Check-ContainerRunning([string]$name) {
    $container = docker ps --filter "name=$name" --format "{{.Names}}"
    if ($LASTEXITCODE -eq 0) {
        return -not [string]::IsNullOrEmpty($container)
    } else {
        Write-Host "✗ Docker command for Container '$Name failed with exit code $LASTEXITCODE." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

function Check-ContainerHealthy([string]$name) {
    $status = docker ps --filter "name=$name" --format "{{.Status}}"
    if ($LASTEXITCODE -eq 0) {
        return ($status  -match "up" -or $status -match "healthy"  -or $status -match "Up")
    } else {
        Write-Host "✗ Docker command for Container '$Name failed with exit code $LASTEXITCODE." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

function Wait-ForContainer([string]$name, [string] $fullName,  [int]$maxAttempts = 30, [int]$delaySeconds = 10) {
    $attempt = 0
    Write-Host "Waiting for $fullName to be healthy..." -ForegroundColor Yellow
    do {
        $attempt++
        if ((Check-ContainerHealthy -name $name)) {
            return $true
        }
        Write-Host "Waiting for $fullName to be healthy (attempt $attempt of $maxAttempts)..." -ForegroundColor Yellow
        Start-Sleep -Seconds $delaySeconds
    } while ($attempt -lt $maxAttempts)
    
    return $false
}

function Start-Container([string]$name, [string] $fullName) {
    Write-Host "🚀 Starting $fullName..." -ForegroundColor Cyan
    
    if ((Check-ContainerRunning -name  $name)) {
        Write-Host "$name is already running!" -ForegroundColor Green
        return
    }

    if ((Check-ContainerExists -name  $name)) {
        Write-Host "Starting existing $name container..." -ForegroundColor Yellow
        docker start $name
    } else {
        Write-Host "Creating and starting new $name container..." -ForegroundColor Yellow
        docker-compose up -d $name
    }
}

function Stop-Container([string]$name, [string] $fullName) {
    Write-Host "🛑 Stopping $fullName..." -ForegroundColor Cyan
    
    if (-not (Check-ContainerRunning -name  $name)) {
        Write-Host "$name is not running!" -ForegroundColor Yellow
        return
    }
    
    # Stop the container
    docker stop $name
    
    # Verify the container is stopped
    $stillRunning = Check-ContainerRunning -name  $name
    if (-not $stillRunning) {
        Write-Host "✓ $fullName has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to stop $fullName!" -ForegroundColor Red
    }
}

function Start-Azurite {
    # Create azurite directory if it doesn't exist
    if (-not (Test-Path ".\azurite")) {
        New-Item -ItemType Directory -Path ".\azurite"
    }
    Start-Container -Name $Azurite -FullName "Azurite storage emulator"
    
    # Verify the container is running
    $running = Check-ContainerRunning -name  $Azurite
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
    stop-Container -Name $Azurite -FullName "Azurite storage emulator"
}

function Start-CosmosDb {
    Start-Container -Name $CosmosDb -FullName "CosmosDB emulator"
    
    $ready = Wait-ForContainer -name $CosmosDb -fullName "CosmosDB emulator" -maxAttempts 30 -delaySeconds 10
   
    if ($ready) {
        Write-Host "CosmosDB emulator is now running!" -ForegroundColor Green
        Write-Host "Endpoint: https://localhost:8081" -ForegroundColor White
        Write-Host "Primary Key: C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==" -ForegroundColor White
    } else {
        Write-Host "Failed to start CosmosDB emulator or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-CosmosDb {
    stop-Container -Name $CosmosDb -FullName "CosmosDB emulator"
   
    if (-not (Check-ContainerRunning -name  $CosmosDb)) {
        Write-Host "CosmosDB emulator is not running!" -ForegroundColor Yellow
        return
    }
    # Verify the container is stopped
    $stillRunning = Check-ContainerRunning -name  $CosmosDb
    if (-not $stillRunning) {
        Write-Host "CosmosDB emulator has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop CosmosDB emulator!" -ForegroundColor Red
    }
}

function Start-MsSql {
    Start-Container -Name $MsSql -FullName "MSSQL Server"
    
    $ready = Wait-ForContainer -name $MsSql -fullName "MSSQL Server" -maxAttempts 12 -delaySeconds 10
    
    if ($ready) {
        Write-Host "MSSQL Server is now running!" -ForegroundColor Green
        Write-Host "Connection String: Server=localhost,1433;Database=master;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True" -ForegroundColor White
    } else {
        Write-Host "Failed to start MSSQL Server or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-MsSql {
    Stop-Container -Name $MsSql -FullName "MSSQL Server"    
    
    $stillRunning = Check-ContainerRunning -name  $MsSql
    if (-not $stillRunning) {
        Write-Host "MSSQL Server has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop MSSQL Server!" -ForegroundColor Red
    }
}

function Start-SqlEdge {
    start-Container -Name $SqlEdge -FullName "SQL Edge"

    $ready = Wait-ForContainer -name $SqlEdge -fullName "SQL Edge" -maxAttempts 12 -delaySeconds 10
   
    if ($ready) {
        Write-Host "SQL Edge is now running!" -ForegroundColor Green
        Write-Host "Connection String: Server=localhost,14333;Database=master;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True" -ForegroundColor White
    } else {
        Write-Host "Failed to start SQL Edge or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-SqlEdge {
    stop-Container -Name $SqlEdge -FullName "SQL Edge"
    
    $stillRunning = Check-ContainerRunning -name  $SqlEdge
    if (-not $stillRunning) {
        Write-Host "SQL Edge has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop SQL Edge!" -ForegroundColor Red
    }
}

function Start-ServiceBus {
    Write-Host "Starting Service Bus emulator..." -ForegroundColor Cyan
    
    # First check if SQL Edge is running as Service Bus depends on it
    $sqlEdgeRunning =  Check-ContainerRunning -name  $SqlEdge
    if (-not $sqlEdgeRunning) {
        Write-Host "SQL Edge is required for Service Bus emulator. Starting SQL Edge first..." -ForegroundColor Yellow
        Start-SqlEdge
    }
    
    Start-Container -Name $ServiceBus -FullName "Service Bus emulator"
    
    $ready = Wait-ForContainer -name $ServiceBus -fullName "Service Bus emulator" -maxAttempts 12 -delaySeconds 10
    
    if ($ready) {
        Write-Host "Service Bus emulator is now running!" -ForegroundColor Green
        Write-Host "AMQP Endpoint: amqp://localhost:5672" -ForegroundColor White
        Write-Host "Management Endpoint: http://localhost:5300" -ForegroundColor White
    } else {
        Write-Host "Failed to start Service Bus emulator or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-ServiceBus {
    stop-Container -Name $ServiceBus -FullName "Service Bus emulator"
    
    $stillRunning = Check-ContainerRunning -name  $ServiceBus
    if (-not $stillRunning) {
        Write-Host "Service Bus emulator has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop Service Bus emulator!" -ForegroundColor Red
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
        "start-mssql" {
            Start-MsSql
        }
        "stop-mssql" {
            Stop-MsSql
        }
        "start-sqledge" {
            Start-SqlEdge
        }
        "stop-sqledge" {
            Stop-SqlEdge
        }
        "start-servicebus" {
            Start-ServiceBus
        }
        "stop-servicebus" {
            Stop-ServiceBus
        }
        default {
            Show-Help
        }
    }
}

# Run the main function with parsed parameters
Run-Main -command $Command