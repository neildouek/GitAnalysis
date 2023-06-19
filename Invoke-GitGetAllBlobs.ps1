function Invoke-GitGetAllBlobs {
    param (        
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )
 


    try {
        Set-Location $RepoPath
       
        # Define a new array to hold all blobs
$allBlobs = @()


# Get a list of all blob hashes and their associated paths
$blobs = git rev-list --all --objects | %{ 
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

            # Get the blob size
            $blobSize = git cat-file -s $blobHash

            # Get the blob type
             $blobType = git cat-file -t $blobHash

            # Get the author of the most recent commit
            $author = git log -1 --pretty=format:"%an" $blobHash

            $blobFullDetail = @{
                
                'Type'   = $blobType
                'Hash'   = $blobHash
                'Path'   = $blobPath
                'Size'   = $blobSize
                'Author' = $author
            }
            $allBlobs += $blobFullDetail
        }

        

        $result.Value = $allBlobs
        $result.Success = $true
        $result.Comment = "The reposiotry contains "+$allBlobs.Count+" blobs."
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}


Set-Location $RepoPath
# Get a list of all commits in the repo
$commits = git rev-list --all

$automationFiles = @()

foreach ($commit in $commits) {
    # Get the tree for this commit
    $tree = git ls-tree -r $commit

    foreach ($file in $devopsFiles) {
        # Check if this tree contains a file that matches the pattern
        $matchedFiles = $tree | Where-Object { $_.Split('\t')[1] -like $file }

        foreach ($matchedFile in $matchedFiles) {
            $hash = $matchedFile.Split('\t')[0].Split(' ')[2]
            $path = $matchedFile.Split('\t')[1]
            $branches = git branch --contains $commit

            # Construct an object with file details and branches where it was found
            $fileDetails = @{
                'Hash' = $hash
                'Path' = $path
                'Commit' = $commit
                'Branches' = $branches
            }

            $automationFiles += $fileDetails
        }
    }
}

$automationFiles