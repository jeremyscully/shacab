# Create and configure the shacab database
# This script creates the database and applies all table and stored procedure scripts

# Database connection parameters
$serverInstance = "(localdb)\MSSQLLocalDB"
$databaseName = "shacab"

Write-Host "Starting database creation process for $databaseName on $serverInstance..." -ForegroundColor Cyan

# Create the database if it doesn't exist
try {
    $query = "IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'$databaseName')
              BEGIN
                  CREATE DATABASE [$databaseName]
                  PRINT 'Database $databaseName created successfully.'
              END
              ELSE
              BEGIN
                  PRINT 'Database $databaseName already exists.'
              END"
    
    # Create a temporary SQL file
    $tempFile = [System.IO.Path]::GetTempFileName() + ".sql"
    $query | Out-File -FilePath $tempFile -Encoding utf8
    
    # Execute the SQL using sqlcmd
    $output = sqlcmd -S $serverInstance -i $tempFile
    Write-Host $output
    
    # Remove the temporary file
    Remove-Item $tempFile
    
    Write-Host "Database check/creation completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error creating database: $_" -ForegroundColor Red
    exit 1
}

# Function to execute SQL scripts in a directory in numerical order
function Execute-SqlScripts {
    param (
        [string]$scriptsPath,
        [string]$scriptType
    )
    
    if (!(Test-Path $scriptsPath)) {
        Write-Host "Warning: Path $scriptsPath does not exist." -ForegroundColor Yellow
        return
    }
    
    $scripts = Get-ChildItem -Path $scriptsPath -Filter "*.sql" | Sort-Object Name
    
    if ($scripts.Count -eq 0) {
        Write-Host "No SQL scripts found in $scriptsPath" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Executing $scriptType scripts..." -ForegroundColor Cyan
    
    foreach ($script in $scripts) {
        $scriptContent = Get-Content -Path $script.FullName -Raw
        
        # Skip empty scripts
        if ([string]::IsNullOrWhiteSpace($scriptContent)) {
            Write-Host "Skipping empty script: $($script.Name)" -ForegroundColor Yellow
            continue
        }
        
        Write-Host "Executing script: $($script.Name)" -ForegroundColor White
        
        # Create a temporary file with GO statements to ensure proper batch execution
        $tempFile = [System.IO.Path]::GetTempFileName() + ".sql"
        $scriptContent | Out-File -FilePath $tempFile -Encoding utf8
        
        # Execute the SQL script using sqlcmd with error output
        $process = Start-Process -FilePath "sqlcmd" -ArgumentList "-S", $serverInstance, "-d", $databaseName, "-i", $tempFile, "-b", "-v", "SQLCMDMAXVARTYPEWIDTH=2000", "-v", "SQLCMDMAXFIXEDTYPEWIDTH=2000" -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$tempFile.out" -RedirectStandardError "$tempFile.err"
        
        if ($process.ExitCode -ne 0) {
            $errorOutput = Get-Content "$tempFile.err" -Raw
            $standardOutput = Get-Content "$tempFile.out" -Raw
            Write-Host "Error executing script $($script.Name):" -ForegroundColor Red
            Write-Host "Standard Output: $standardOutput" -ForegroundColor Yellow
            Write-Host "Error Output: $errorOutput" -ForegroundColor Red
            
            # Display the SQL that caused the error
            Write-Host "SQL Script Content:" -ForegroundColor Yellow
            Write-Host $scriptContent -ForegroundColor Yellow
        }
        else {
            $output = Get-Content "$tempFile.out" -Raw
            Write-Host $output
            Write-Host "Script executed successfully: $($script.Name)" -ForegroundColor Green
        }
        
        # Clean up temporary files
        Remove-Item $tempFile -ErrorAction SilentlyContinue
        Remove-Item "$tempFile.out" -ErrorAction SilentlyContinue
        Remove-Item "$tempFile.err" -ErrorAction SilentlyContinue
    }
}

# Get the current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Execute table scripts first (they create the database schema)
$tablesPath = Join-Path $scriptDir "tables"
Execute-SqlScripts -scriptsPath $tablesPath -scriptType "table"

# Execute stored procedure scripts
$storedProceduresPath = Join-Path $scriptDir "stored_procedures"
Execute-SqlScripts -scriptsPath $storedProceduresPath -scriptType "stored procedure"

Write-Host "Database setup completed." -ForegroundColor Green
