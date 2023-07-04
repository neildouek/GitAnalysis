function check-GitContributors {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )


    try {
        Set-Location $params.RepoPath
      
        $contributors = git shortlog -sne | ForEach-Object {
            $parts = $_ -split '\t'
            $commits = $parts[0].Trim()
            $nameEmailParts = $parts[1].Trim() -split '<'
            $name = $nameEmailParts[0].Trim()
            $email = $nameEmailParts[1].Trim('>')
            @{
                'name' = $name
                'email' = $email
                'commits' = $commits
            }
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

