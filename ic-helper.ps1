function Test-GitRepositoryClean {
    param (
        [Parameter(Mandatory=$true)]
        [string]$directory,
        [switch]$force
    )

    # Perform dry run of git clean -xfd command
    $output = git -C $directory clean -nxfd | Select-String -SimpleMatch -CaseSensitive -Pattern "Would remove" | Measure-Object
    if ($output.Count -gt 0) {
        Write-Host "This repository can be cleaned. Number of objects that would be removed: $($output.Count)"
        if ($force) {
            git -C $directory clean -xfd
            Get-CommandStatus -command "clean"
        } else {
            $response = Read-Host "Would you like to clean this repository? (Y/N)"
            if ($response -eq "Y" -or $response -eq "y") {
                git -C $directory clean -xfd
                Get-CommandStatus -command "clean"
            }
        }
    } else {
        Write-Host -ForegroundColor Green "This repository is clean."
    }
}

function Get-CommandStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$command
    )

    if ($LASTEXITCODE -eq 0) {
        Write-Host -ForegroundColor Green "Successfully $($command)ed the repository."
    } else {
        $titleCase = (Get-Culture).TextInfo.ToTitleCase($command)
        Write-Host -ForegroundColor Yellow "$titleCase finished with errors, see messages above."
    }
}

function Invoke-GitFetch {
    param (
        [Parameter(Mandatory=$true)]
        [string]$directory
    )
    git -C $directory fetch
}

function Invoke-GitPull {
    param (
        [Parameter(Mandatory=$true)]
        [string]$directory,
        [switch]$force
    )
    if ($force) {
        git -C $directory pull --force
    } else {
        git -C $directory pull
    }
}

function Find-GitRepositories {
    param (
        [Parameter(Mandatory=$true)]
        [string]$path,
        [string]$command,
        [switch]$force
    )

 # Check if the path exists

$foundRepository = $false

try {
    $subdirs = Get-ChildItem -Path $path -Directory -Recurse -ErrorAction Stop
} catch [System.Management.Automation.ItemNotFoundException] {
    # Catch if the specified path exists, and throw an error if it doesn't
    throw "The specified path '$path' does not exist."
} catch {
    # Catch any other exception that might occur
    Write-Error "The specified path '$path' does not exist."
 exit 1
}
    foreach ($dir in $subdirs) {
        $gitDir = Join-Path $dir.FullName ".git"
        if (Test-Path $gitDir) {
            $foundRepository = $true
            Write-Host -ForegroundColor Blue "`nFound git repository at $($dir.FullName)"
            switch ( $command ) {
                "clean" { Test-GitRepositoryClean -directory $dir.FullName -force:$force }
                "fetch" {
                    Invoke-GitFetch -directory $dir.FullName
                    Get-CommandStatus -command $command
                }
                "pull"  {
                   Invoke-GitPull -directory $dir.FullName -force:$force
                   Get-CommandStatus -command $command
                }
                default { throw "${command}: command not found." }
            }
        }
    }

    if (!$foundRepository) {
        # If no repository was found it returns a message stating that the any repository was found in the specified path
        Write-Host -ForegroundColor White "No Git repositories were found in directory $path"
    }
}

function Show-Help {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptName
    )

    Write-Host "IC Helper Script scans for Git repositories at a given path and performs various operations on them.`n"
    Write-Host "Usage: .\$scriptName <command> <path> [-force]`n"
    Write-Host "Commands:`n"
    Write-Host "clean:`n`tExecute git clean -xfd on all repositories.
         When -force option is specified, do this without prompting for user confirmation.`n"
    Write-Host "pull:`n`tExecute git pull on all repositories. When -force option is specified, do force pulling."
    Write-Host "fetch:`n`tExecute git fetch on all repositories."
    Write-Host "help or /?:`n`tPrint this help and exit."
}

if ($args.Length -eq 0 -or $args[0] -eq "help" -or $args[0] -eq "/?") {
    Show-Help -ScriptName $MyInvocation.MyCommand.Name
    exit 1
}

Find-GitRepositories -command $args[0] -path $args[1] -force:$args.Contains("-force")