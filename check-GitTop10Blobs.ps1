function check-GitTop10Blobs {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )

    try {
        Set-Location $params.RepoPath
        $blobs = @()
        git ls-tree -r HEAD | ForEach-Object {
        $permissions, $type, $hash, $path = $_ -split '\s+', 4
        if ($type -eq "blob") {
            $size = git cat-file -s $hash
            $item = @{
                'Hash' = $hash
                'Path' = $path
                'Size' = $size
            }
        $blobs += $item
            }
        }
        $blobs = $blobs | Sort-Object -Property Size -Descending | Select-Object -First 10

        $result.Value = $blobs
        $result.Success = $true
        $result.Comment = "The largest blob is "+$blobs[0].Size

    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

