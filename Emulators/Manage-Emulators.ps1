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

function Start-MsSql {
    Write-Host "Starting MSSQL Server..." -ForegroundColor Cyan
    
    # Check if container exists and is running
    $containerExists = docker ps -a --filter "name=mssql" --format "{{.Names}}"
    $containerRunning = docker ps --filter "name=mssql" --format "{{.Names}}"
    
    if ($containerRunning) {
        Write-Host "MSSQL Server is already running!" -ForegroundColor Green
        Write-Host "Connection String: Server=localhost,1433;Database=master;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True" -ForegroundColor White
        return
    }
    
    if ($containerExists) {
        Write-Host "Starting existing MSSQL container..." -ForegroundColor Yellow
        docker start mssql
    } else {
        Write-Host "Creating and starting new MSSQL container..." -ForegroundColor Yellow
        docker-compose up -d mssql
    }
    
    # Wait for the container to be healthy
    Write-Host "Waiting for MSSQL Server to be ready..." -ForegroundColor Yellow
    $maxAttempts = 12
    $attempt = 0
    $ready = $false
    
    do {
        $attempt++
        $status = docker ps --filter "name=mssql" --format "{{.Status}}"
        if ($status -match "healthy" -or $status -match "Up") {
            $ready = $true
            break
        }
        Write-Host "Waiting for MSSQL Server to start (attempt $attempt of $maxAttempts)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    } while ($attempt -lt $maxAttempts)
    
    if ($ready) {
        Write-Host "MSSQL Server is now running!" -ForegroundColor Green
        Write-Host "Connection String: Server=localhost,1433;Database=master;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True" -ForegroundColor White
    } else {
        Write-Host "Failed to start MSSQL Server or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-MsSql {
    Write-Host "Stopping MSSQL Server..." -ForegroundColor Cyan
    
    $containerRunning = docker ps --filter "name=mssql" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "MSSQL Server is not running!" -ForegroundColor Yellow
        return
    }
    
    docker stop mssql
    
    $stillRunning = docker ps --filter "name=mssql" --format "{{.Names}}"
    if (-not $stillRunning) {
        Write-Host "MSSQL Server has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop MSSQL Server!" -ForegroundColor Red
    }
}

function Start-SqlEdge {
    Write-Host "Starting SQL Edge..." -ForegroundColor Cyan
    
    $containerExists = docker ps -a --filter "name=sqledge" --format "{{.Names}}"
    $containerRunning = docker ps --filter "name=sqledge" --format "{{.Names}}"
    
    if ($containerRunning) {
        Write-Host "SQL Edge is already running!" -ForegroundColor Green
        Write-Host "Connection String: Server=localhost,14333;Database=master;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True" -ForegroundColor White
        return
    }
    
    if ($containerExists) {
        Write-Host "Starting existing SQL Edge container..." -ForegroundColor Yellow
        docker start sqledge
    } else {
        Write-Host "Creating and starting new SQL Edge container..." -ForegroundColor Yellow
        docker-compose up -d sqledge
    }
    
    # Wait for the container to be ready
    Write-Host "Waiting for SQL Edge to be ready..." -ForegroundColor Yellow
    $maxAttempts = 12
    $attempt = 0
    $ready = $false
    
    do {
        $attempt++
        $status = docker ps --filter "name=sqledge" --format "{{.Status}}"
        if ($status -match "healthy" -or $status -match "Up") {
            $ready = $true
            break
        }
        Write-Host "Waiting for SQL Edge to start (attempt $attempt of $maxAttempts)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    } while ($attempt -lt $maxAttempts)
    
    if ($ready) {
        Write-Host "SQL Edge is now running!" -ForegroundColor Green
        Write-Host "Connection String: Server=localhost,14333;Database=master;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True" -ForegroundColor White
    } else {
        Write-Host "Failed to start SQL Edge or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-SqlEdge {
    Write-Host "Stopping SQL Edge..." -ForegroundColor Cyan
    
    $containerRunning = docker ps --filter "name=sqledge" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "SQL Edge is not running!" -ForegroundColor Yellow
        return
    }
    
    docker stop sqledge
    
    $stillRunning = docker ps --filter "name=sqledge" --format "{{.Names}}"
    if (-not $stillRunning) {
        Write-Host "SQL Edge has been stopped successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to stop SQL Edge!" -ForegroundColor Red
    }
}

function Start-ServiceBus {
    Write-Host "Starting Service Bus emulator..." -ForegroundColor Cyan
    
    # First check if SQL Edge is running as Service Bus depends on it
    $sqlEdgeRunning = docker ps --filter "name=sqledge" --format "{{.Names}}"
    if (-not $sqlEdgeRunning) {
        Write-Host "SQL Edge is required for Service Bus emulator. Starting SQL Edge first..." -ForegroundColor Yellow
        Start-SqlEdge
    }
    
    $containerExists = docker ps -a --filter "name=servicebus-emulator" --format "{{.Names}}"
    $containerRunning = docker ps --filter "name=servicebus-emulator" --format "{{.Names}}"
    
    if ($containerRunning) {
        Write-Host "Service Bus emulator is already running!" -ForegroundColor Green
        Write-Host "AMQP Endpoint: amqp://localhost:5672" -ForegroundColor White
        Write-Host "Management Endpoint: http://localhost:5300" -ForegroundColor White
        return
    }
    
    if ($containerExists) {
        Write-Host "Starting existing Service Bus emulator container..." -ForegroundColor Yellow
        docker start servicebus-emulator
    } else {
        Write-Host "Creating and starting new Service Bus emulator container..." -ForegroundColor Yellow
        docker-compose up -d servicebus-emulator
    }
    
    # Wait for the container to be ready
    Write-Host "Waiting for Service Bus emulator to be ready..." -ForegroundColor Yellow
    $maxAttempts = 12
    $attempt = 0
    $ready = $false
    
    do {
        $attempt++
        $status = docker ps --filter "name=servicebus-emulator" --format "{{.Status}}"
        if ($status -match "healthy" -or $status -match "Up") {
            $ready = $true
            break
        }
        Write-Host "Waiting for Service Bus emulator to start (attempt $attempt of $maxAttempts)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    } while ($attempt -lt $maxAttempts)
    
    if ($ready) {
        Write-Host "Service Bus emulator is now running!" -ForegroundColor Green
        Write-Host "AMQP Endpoint: amqp://localhost:5672" -ForegroundColor White
        Write-Host "Management Endpoint: http://localhost:5300" -ForegroundColor White
    } else {
        Write-Host "Failed to start Service Bus emulator or timed out waiting for it to be ready!" -ForegroundColor Red
    }
}

function Stop-ServiceBus {
    Write-Host "Stopping Service Bus emulator..." -ForegroundColor Cyan
    
    $containerRunning = docker ps --filter "name=servicebus-emulator" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "Service Bus emulator is not running!" -ForegroundColor Yellow
        return
    }
    
    docker stop servicebus-emulator
    
    $stillRunning = docker ps --filter "name=servicebus-emulator" --format "{{.Names}}"
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