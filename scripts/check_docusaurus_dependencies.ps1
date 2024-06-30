# Required versions (stripped of 'v' prefix)
$requiredNodeVersion = "20.15.0"
$requiredNpmVersion = "10.7.0"
$requiredNpxVersion = "10.7.0"

# Function to compare versions
function Compare-Versions {
    param (
        [string]$version1,
        [string]$version2
    )

    # Strip 'v' prefix from version strings
    $strippedVersion1 = $version1.TrimStart('v')
    $strippedVersion2 = $version2.TrimStart('v')

    # Compare stripped versions
    return [version]$strippedVersion1 -ge [version]$strippedVersion2
}

# Function to check Node.js version
function Check-NodeVersion {
    $nodeVersion = node -v
    if (Compare-Versions $nodeVersion $requiredNodeVersion) {
        Write-Output "Node.js version is $nodeVersion (required: v$requiredNodeVersion or above)"
    } else {
        Write-Output "Node.js version is $nodeVersion, which is less than the required version v$requiredNodeVersion"
        exit 1
    }
}

# Function to check npm version
function Check-NpmVersion {
    $npmVersion = npm -v
    if (Compare-Versions $npmVersion $requiredNpmVersion) {
        Write-Output "npm version is $npmVersion (required: v$requiredNpmVersion or above)"
    } else {
        Write-Output "npm version is $npmVersion, which is less than the required version v$requiredNpmVersion"
        exit 1
    }
}

# Function to check npx version
function Check-NpxVersion {
    $npxVersion = npx -v
    if (Compare-Versions $npxVersion $requiredNpxVersion) {
        Write-Output "npx version is $npxVersion (required: v$requiredNpxVersion or above)"
    } else {
        Write-Output "npx version is $npxVersion, which is less than the required version v$requiredNpxVersion"
        exit 1
    }
}

# Main function
function Main {
    # Parse command line arguments
    if ($args.Count -gt 0 -and $args[0] -eq "--help") {
        Help
        return
    }

    Check-NodeVersion
    Check-NpmVersion
    Check-NpxVersion
}

# Help function
function Help {
    Write-Output "Usage: $PSCommandPath [--help]"
    Write-Output "Checks if the required dependencies are met for running Docusaurus."
    Write-Output ""
    Write-Output "Options:"
    Write-Output "  --help   Display this help message"
}

# Call the main function with command line arguments
Main $args
