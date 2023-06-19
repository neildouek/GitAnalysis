function Invoke-ReadBranchesAndTags {
    
    param (
        [Parameter(Mandatory = $true)]
        [string]$WorkingDir
    )

    try {
        Write-Host "Verifying branches and tags..."
        $branches = git -C $WorkingDir branch --format="%(refname:short)"
        $tags = git -C $WorkingDir tag --list

        # Verify branches
        foreach ($branch in $branches) {
            $branchExists = git -C $WorkingDir show-ref --quiet --verify "refs/heads/$branch"
            if (-not $branchExists) {
                throw "-- Branch '$branch' is invalid or no longer exists."
            }
        }

        # Verify tags
        foreach ($tag in $tags) {
            $tagExists = git -C $WorkingDir show-ref --quiet --verify "refs/tags/$tag"
            if (-not $tagExists) {
                throw "-- Tag '$tag' is invalid or no longer exists."
            }
        }

        Write-Host "Branch and tag verification completed."
        return @{
            Status = "Success"
            ErrorMessage = $null
        }
    }
    catch {
        Write-Host "An error occurred during branch and tag verification:"
        Write-Host $_
        return @{
            Status = "Error"
            ErrorMessage = $_.Exception.Message
        }
    }
}

