function check-GitRepoSize {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )
   
    try {

        Set-Location $params.RepoPath
        
        $size = (Get-ChildItem -Path $RepoPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
               
        $result.Value = $size
        $result.Comment = "The repository size is $size."
        $result.Success = $true
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

