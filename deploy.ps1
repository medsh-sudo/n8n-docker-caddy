# n8n Deployment Script for PowerShell
# This script automates the deployment of n8n using Ansible

param(
    [string]$EnvironmentFile = "ansible.env"
)

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if ansible is installed
function Test-Ansible {
    try {
        $null = Get-Command ansible -ErrorAction Stop
        Write-Status "Ansible is installed"
        return $true
    }
    catch {
        Write-Error "Ansible is not installed. Please install Ansible first."
        return $false
    }
}

# Check if ansible.env exists
function Test-EnvFile {
    param([string]$EnvFile)
    
    if (Test-Path $EnvFile) {
        Write-Status "Environment file found: $EnvFile"
        return $true
    }
    else {
        Write-Error "Environment file not found: $EnvFile. Please create it first."
        return $false
    }
}

# Load environment variables
function Load-Environment {
    param([string]$EnvFile)
    
    Write-Status "Loading environment variables from $EnvFile..."
    
    if (Test-Path $EnvFile) {
        Get-Content $EnvFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                $name = $matches[1]
                $value = $matches[2]
                Set-Variable -Name $name -Value $value -Scope Global
            }
        }
        Write-Status "Environment variables loaded"
    }
}

# Test connection to target server
function Test-Connection {
    Write-Status "Testing connection to target server..."
    
    try {
        $result = ansible n8n_servers -m ping 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Connection successful"
            return $true
        }
        else {
            Write-Error "Connection failed. Please check your SSH configuration."
            Write-Host $result
            return $false
        }
    }
    catch {
        Write-Error "Failed to test connection: $($_.Exception.Message)"
        return $false
    }
}

# Deploy n8n
function Deploy-N8N {
    Write-Status "Starting n8n deployment..."
    
    try {
        $result = ansible-playbook playbook.yml
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Deployment completed successfully!"
            Write-Status "n8n is now available at: http://$N8N_HOST_IP:$N8N_PORT"
            Write-Warning "Default credentials: admin / (check .env file for password)"
            return $true
        }
        else {
            Write-Error "Deployment failed. Please check the logs above."
            return $false
        }
    }
    catch {
        Write-Error "Failed to deploy: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
function Main {
    Write-Status "Starting n8n deployment process..."
    
    # Check prerequisites
    if (-not (Test-Ansible)) { exit 1 }
    if (-not (Test-EnvFile -EnvFile $EnvironmentFile)) { exit 1 }
    
    # Load environment and deploy
    Load-Environment -EnvFile $EnvironmentFile
    if (-not (Test-Connection)) { exit 1 }
    if (-not (Deploy-N8N)) { exit 1 }
    
    Write-Status "Deployment process completed!"
}

# Run main function
Main
