function Invoke-CloneRepo {
    

    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )


    try {

        

        if ($params.RepoSource -match '^https?://') {
            # Clone from URL
            Write-Host "Cloning from URL: "+$params.repoSource
            git clone $params.repoSource             
            git fetch --all
            # Verify if the clone operation was successful
            if (-not (Test-Path $WorkingDir)) {
                throw "Repository not found."
            }

            $result.Success = $true
            $result.Comment = "The repo was cloned successfully."
        }
        else {
            throw
        }
                
      
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}