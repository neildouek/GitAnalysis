function check-GitDevOpsFiles {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )
 

    try {
        Set-Location $params.RepoPath
       
        $devopsFiles = @("*azure*.yml", "*.yml", ".github/workflows/*", ".gitlab-ci.yml", "Jenkinsfile", "circle.yml", ".travis.yml", "bamboo-specs/bamboo.yml", "azure-pipelines.yml")

        # Get a list of all blob paths in the repo, across all branches
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

        $automationFiles = @()

        foreach ($blob in $blobs) {
            foreach ($file in $devopsFiles) {
                if ($blob.Path -like $file) {
                    Write-Host ("Found: $file")
                    $automationFiles += $blob
                    break;
                }
            }
        }




        $result.Value = $automationFiles
        $result.Success = $true
        $result.Comment = "The repo contains "+$automationFiles.Count + " DevOps file(s)."
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

