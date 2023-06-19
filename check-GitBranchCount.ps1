function check-GitBranchCount {
    param (        
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )
   
    try {

               
        Set-Location $RepoPath        
        $branchCount = git branch --format="%(refname:short)" | Measure-Object | Select-Object -ExpandProperty Count
               
        $result.Value = $branchCount
        $result.Comment = "The repository has ${branchCount} branch(s)"
        $result.Success = $true
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

