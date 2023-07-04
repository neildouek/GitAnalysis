function Invoke-GitGetAllBlobs {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )

    try {
        Set-Location $params.RepoPath
       
        # Define a new list to hold all blobs
        $allBlobs = New-Object System.Collections.Generic.List[object]

        # Get a list of all blob hashes and their associated paths
        $blobs = git rev-list --all --objects | ForEach-Object { 
            $blobData = $_.Split(' ')
            $blobHash = $blobData[0]
            $blobPath = $blobData[1]

            $blobDetail = @{
                'Hash' = $blobHash
                'Path' = $blobPath
            }
            $blobDetail
        }

        foreach ($blob in $blobs) {
            $blobHash = $blob['Hash']
            $blobPath = $blob['Path']

            # Get the blob size and type
            $blobData = git cat-file -p $blobHash | Out-String
            $blobSize = $blobData.Split("`n")[0].Split(' ')[2]
            $blobType = $blobData.Split("`n")[0].Split(' ')[1]

            # Get the author of the most recent commit
            $author = git log -1 --pretty=format:"%an" $blobHash

            $blobFullDetail = @{
                'Type'   = $blobType
                'Hash'   = $blobHash
                'Path'   = $blobPath
                'Size'   = $blobSize
                'Author' = $author
            }
            $allBlobs.Add($blobFullDetail)

            Write-Host($blobFullDetail)
        }

        $result.Value = $allBlobs
        $result.Success = $true
        $result.Comment = "The repository contains "+$allBlobs.Count+" blobs."
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}
