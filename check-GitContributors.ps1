function check-GitContributors {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )

    

    try {
        Set-Location $params.RepoPath
      
        $contributors = git shortlog -e --summary --numbered | ForEach-Object {
            $contributor = $_.Trim().Split(' ', 2)
            $hash = @{
                'email' = $contributor[1]
                'commits' = $contributor[0]
            }
            @{ $contributor[1] = $hash }
        }

        $result.Value = $contributors       
        $result.Success = $true
        $result.Comment = "The repo contains "+$contributors.Count + " contributor(s)."
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

