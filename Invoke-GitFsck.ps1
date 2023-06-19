function Invoke-GitFsck {
    <#
    .SYNOPSIS
    Runs the 'git fsck' command on a Git repository in the specified working directory.

    .DESCRIPTION
    This function runs the 'git fsck' command on a Git repository in the specified working directory.
    It checks the integrity and consistency of the repository's objects and their relationships.
    The function outputs any detected issues and error messages reported by the 'git fsck' command.

    .PARAMETER WorkingDir
    Specifies the working directory where the Git repository is located.

    .OUTPUTS
    [bool] True if the checks passed; otherwise, False.

    .EXAMPLE
    $checksPassed = Invoke-GitFsck -WorkingDir "C:\path\to\working\directory"
    if ($checksPassed) {
        Write-Host "Git repository passed the health check"
    }
    else {
        Write-Host "Git repository has issues"
    }
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$WorkingDir
    )

    try {
        # Change the working directory to the specified path
        Set-Location -Path $WorkingDir

        # Run 'git fsck' command
        & git fsck

        # Check the exit code to determine the result
        $checksPassed = $LASTEXITCODE -eq 0

        # Return the result
        return $checksPassed
    }
    catch {
        Write-Host "An error occurred while running 'git fsck':"
        Write-Host $_.Exception.Message
        return $false
    }
}
