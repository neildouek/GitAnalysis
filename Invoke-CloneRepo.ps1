function Invoke-CloneRepo {
    

    param (        
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )


    try {

        

        if ($RepoSource -match '^https?://') {
            # Clone from URL
            Write-Host "Cloning from URL: $RepoSource"
            git clone $RepoSource             
            git fetch --all
            # Verify if the clone operation was successful
            if (-not (Test-Path $WorkingDir)) {
                throw "Repository not found."
            }
        }
        else {
            # Clone from local path
            Write-Host "Initializing empty repository in $WorkingDir"
            & git init $WorkingDir | Out-Null

            Write-Host "Setting origin to $RepoSource"
            & git -C $WorkingDir remote add origin $RepoSource | Out-Null

            Write-Host "Pulling repository from origin/main to $WorkingDir"
            & git -C $WorkingDir pull origin main --depth=1 | Out-Null
        }
        $result.Value = "$WorkingDir/repo/"+$RepoPath.Split("/")[-1]            
        $result.Success = $true
        $result.Comment = "The repo was cloned successfully."
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}