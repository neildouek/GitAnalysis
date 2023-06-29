function Invoke-GitFsck {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )


    try {
        # Change the working directory to the specified path
        Set-Location $params.RepoPath

        # Run 'git fsck' command
        $objects = git fsck --full --no-reflogs --unreachable --dangling --cache --no-progress --connectivity-only --name-objects

        if ($null -eq $objects) {
            $result.Comment = "No issues found."
            $result.Success = $true
        } else {
            $result.Comment = "The following " + $objects.Count + " issue(s) were found."
            Write-Host $objects
            $result.Success = $false
        }


        # Check the exit code to determine the result            
        $result.Value = $objects
        
    }
    catch {
        Write-Host "An error occurred while running 'git fsck':"
        Write-Host $_.Exception.Message
        $result.Success = $false;
    }

    return $result
}
