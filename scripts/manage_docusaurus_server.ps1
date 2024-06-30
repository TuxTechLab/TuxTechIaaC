# Path to check_dependencies.ps1 script (assumed name)
$CHECK_DEPENDENCIES_SCRIPT = ".\check_docusaurus_dependencies.ps1"

# Function to check dependencies
function Check-Dependencies {
    Write-Output "Checking Dependencies..."
    # Invoke the dependency check script
    $dependencyResult = & $CHECK_DEPENDENCIES_SCRIPT
    if ($dependencyResult) {
        Write-Output "Dependencies check passed."
        return $true
    } else {
        Write-Output "Dependency check failed. Cannot start Docusaurus server."
        return $false
    }
}

# Function to start Docusaurus server
function Start-DocusaurusServer {
    Write-Output "Checking Dependencies - TuxTechIaaC Docusaurus"

    # Check dependencies before starting server
    if (-not (Check-Dependencies)) {
        exit 1
    }

    Write-Output "Starting TuxTechIaaC Documentation Docusaurus server..."
    Set-Location "..\www\tuxtechiaac" -ErrorAction Stop
    Start-Process npm -ArgumentList "start" -NoNewWindow -PassThru
    Write-Output "Starting Node Server in Background. Sleeping for 10 Seconds."
    Start-Sleep -Seconds 10
    Write-Output "TuxTechIaaC Documentation Docusaurus server is running on port 3000"
    Set-Location "..\..\scripts"
}

# function Get-DocusaurusPid {
#     # Get all Node.js processes
#     $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue

#     # Filter processes to find the one running Docusaurus
#     foreach ($process in $nodeProcesses) {
#         try {
#             $commandLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)").CommandLine
#             if ($commandLine -match "docusaurus start") {
#                 return $process.Id
#             }
#         } catch {
#             Write-Output "Unable to get command line for process with PID $($process.Id)"
#         }
#     }

#     # Return $null if no Docusaurus process is found
#     return $null
# }

# Function to stop Docusaurus server
# function Stop-DocusaurusServer {
#     Write-Output "Stopping TuxTechIaaC Documentation Docusaurus server..."
#     $docusaurusPid = Get-DocusaurusPid
#     if ($docusaurusPid) {
#         Write-Output "Docusaurus server is running with PID: $docusaurusPid"
#     } 
#     else 
#     {
#         Write-Output "No running Docusaurus server found."
#     }
# }

# Help function
function Show-Help {
    Write-Output "Usage: $PSCommandPath [--start|--stop|--help]"
    Write-Output "Manage TuxTechIaaC Documentation Docusaurus server."
    Write-Output ""
    Write-Output "Options:"
    Write-Output "  --start    Start the Docusaurus server"
    # Write-Output "  --stop     Stop the Docusaurus server"
    Write-Output "  --help     Display this help message"
}

# Main function
function Main {
    # Parse command-line arguments
    switch ($args[0]) {
        "--start" {
            Start-DocusaurusServer
            break
        }
        # "--stop" {
        #     Stop-DocusaurusServer
        #     break
        # }
        "--help" {
            Show-Help
            break
        }
        default {
            Write-Output "Invalid option: $($args[0])"
            Show-Help
            break
        }
    }
}

# Call the main function with command-line arguments
Main $args
