
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("help", "check", "install", "uninstall",
        "start", "stop", "update", "export", "import",
        "set", "kubectl", "run",
        "install-apps",
        "interactive")]
    [string]$Command = "help")

function Show-Help {
    $sriptName =".\Manage-Emulators.ps1"
    Write-Host "WSL Manager DevBox Script" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: $sriptName -Command <command> [-Name <container_name>]" -ForegroundColor White
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -Command    Command to execute (check, help)" -ForegroundColor White
    Write-Host "  -Name/-n    Container name to check (default: devbox)" -ForegroundColor White
    Write-Host "  -Distro/-d  WSL distribution name (default: Debian)" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  help          Show this help message" -ForegroundColor White
    Write-Host "  check         Check if the specified container is running" -ForegroundColor White
}

function Run-Main(){
    param([string]$command,  [string]$name, [string]$distro, [string]$filePath, [string]$installLocation )
    # Main script logic
    $status
    switch ($command) {
        "help" {
            Show-Help
        }
        default {
            Show-Help
        }
    }
}

# Run the main function with parsed parameters
Run-Main -command $Command