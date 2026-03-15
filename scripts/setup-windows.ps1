# setup-windows.ps1 - Windows PowerShell setup script for Study Raag

Write-Host "🚀 Study Raag Windows Setup" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

# Check execution policy
Write-Host "`n📋 Checking PowerShell execution policy..." -ForegroundColor Yellow
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "⚠️  Execution policy is Restricted" -ForegroundColor Yellow
    Write-Host "Run this to allow scripts:" -ForegroundColor Yellow
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor White
    Write-Host ""
}

# Check Python
Write-Host "🐍 Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "✓ $pythonVersion found" -ForegroundColor Green
} catch {
    Write-Host "✗ Python not found!" -ForegroundColor Red
    Write-Host "Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Check Git
Write-Host "`n📦 Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = & git --version 2>&1
    Write-Host "✓ $gitVersion found" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Git not found (optional)" -ForegroundColor Yellow
    Write-Host "Download from: https://git-scm.com/" -ForegroundColor Yellow
}

# Install Python dependencies
Write-Host "`n📚 Installing Python dependencies..." -ForegroundColor Yellow
if (Test-Path "requirements.txt") {
    Write-Host "Installing from requirements.txt..." -ForegroundColor Cyan
    & pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "⚠️  requirements.txt not found" -ForegroundColor Yellow
}

# Setup configuration
Write-Host "`n⚙️  Setting up configuration..." -ForegroundColor Yellow

$configFiles = @(
    @{Source = "config/credentials.example.yaml"; Target = "config/credentials.yaml"},
    @{Source = ".env.example"; Target = ".env"}
)

foreach ($file in $configFiles) {
    if ((Test-Path $file.Source) -and -not (Test-Path $file.Target)) {
        Copy-Item -Path $file.Source -Destination $file.Target
        Write-Host "✓ Created: $($file.Target)" -ForegroundColor Green
    } elseif (Test-Path $file.Target) {
        Write-Host "ℹ️  Already exists: $($file.Target)" -ForegroundColor Gray
    }
}

# Create necessary directories
Write-Host "`n📁 Creating necessary directories..." -ForegroundColor Yellow
$dirs = @(
    "outputs/marketing/reports",
    "outputs/marketing/logs",
    "outputs/finance/reports",
    "outputs/finance/logs",
    "agents/marketing/cache",
    "agents/marketing/logs"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✓ Created: $dir" -ForegroundColor Green
    }
}

# Test Python environment
Write-Host "`n🧪 Testing Python environment..." -ForegroundColor Yellow
try {
    $testScript = @"
import sys
print(f'Python {sys.version.split()[0]}')
print(f'Executable: {sys.executable}')
"@
    
    $testScript | & python
    Write-Host "✓ Python environment working" -ForegroundColor Green
} catch {
    Write-Host "✗ Python environment test failed" -ForegroundColor Red
}

# Optional: Initialize Git
Write-Host "`n📦 Git configuration..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "✓ Git repository already initialized" -ForegroundColor Green
} else {
    $initGit = Read-Host "Initialize Git repository? (y/n)"
    if ($initGit -eq 'y') {
        try {
            & git init
            Write-Host "✓ Git repository initialized" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Git not available" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n✨ Setup complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Edit credentials: nano config/credentials.yaml" -ForegroundColor White
Write-Host "2. Edit environment: nano .env" -ForegroundColor White
Write-Host "3. Run agent: .\scripts\run-agent.ps1 -Agent marketing" -ForegroundColor White
Write-Host "4. View logs: Get-Content agents/marketing/logs/agent.log -Tail 20" -ForegroundColor White
Write-Host ""
