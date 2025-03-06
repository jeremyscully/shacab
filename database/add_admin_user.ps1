# add_admin_user.ps1
# PowerShell script to execute the add_admin_user.sql script

# Database connection parameters
$serverInstance = "(localdb)\MSSQLLocalDB"
$databaseName = "shacab"
$scriptPath = Join-Path $PSScriptRoot "add_admin_user.sql"

Write-Host "Adding admin user to $databaseName database on $serverInstance..." -ForegroundColor Cyan

try {
    # Check if the script file exists
    if (-not (Test-Path $scriptPath)) {
        Write-Host "Error: SQL script file not found at $scriptPath" -ForegroundColor Red
        exit 1
    }
    
    # Execute the SQL script using sqlcmd
    $output = sqlcmd -S $serverInstance -d $databaseName -i $scriptPath
    Write-Host $output
    
    Write-Host "Script execution completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error executing script: $_" -ForegroundColor Red
    exit 1
} 