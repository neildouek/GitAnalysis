function check-GitBranches {
    param (        
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )

    

    try {
        Set-Location $RepoPath
      
        #Get the branch names (the -r switch is important here and also the where clause)
        $branchNames = git -C $RepoPath branch -r --format="%(refname:lstrip=2)" | where-object { $_ -notmatch 'HEAD' }
        

        if($branchNames.Count -gt 1)
        {
            # Check for trunk-based development
            $trunkBased = $branchNames -contains "main" -or $branchNames -contains "master"
            
            # Check for feature branching
            $featureBranching = $branchNames -notcontains "main" -and $branchNames -notcontains "master" -and $branchNames.Count -gt 1
            
            # Check for Gitflow
            $gitflow = $branchNames -contains "main" -and $branchNames -contains "develop" -and $branchNames -notcontains "master"
            
            # Check for release branching
            $releaseBranching = $branchNames -notcontains "main" -and $branchNames -notcontains "master" -and $branchNames -notcontains "develop" -and $branchNames.Count -gt 1
            
            # Check for environment-specific branches
            $environmentBranching = $branchNames -contains "development" -and $branchNames -contains "staging" -and $branchNames -contains "production"
            
            # Output the results
            $branchingStrategy = "Unknown"
            if ($trunkBased) { $branchingStrategy = "Trunk-Based Development" }
            elseif ($featureBranching) { $branchingStrategy = "Feature Branching" }
            elseif ($gitflow) { $branchingStrategy = "Gitflow" }
            elseif ($releaseBranching) { $branchingStrategy = "Release Branching" }
            elseif ($environmentBranching) { $branchingStrategy = "Environment-Specific Branches" }
        }
        else {
            $branchingStrategy = "Unknown (single branch)"       
        }
        $branchingStrategy

        $branchInfo = @{
            BranchCount = $branchNames.Count
            Strategy = $branchingStrategy
            CountMerges = $null
            CountPR = $null
        }

        
        $branchMasterOrMain = ""
        if($branchNames.contains("origin/master"))
        {
            $branchMasterOrMain = "master"
        }
        elseif($branchNames.contains("origin/main"))
        {
            $branchMasterOrMain = "main"
        }

        $branchesMergedWithMainOrMaster = git branch -r --merged $branchMasterOrMain |  where-object { $_ -notmatch 'HEAD|'+ $branchMasterOrMain }
        $branchInfo.CountMerges = $branchesMergedWithMainOrMaster.Count

        $branchInfo.CountPR = git log --merges --grep='Merge pull request' | grep -c 'Merge pull request'


        $result.Value = $branchInfo       
        $result.Success = $true
        $result.Comment = "The repo contains "+$branchNames.Count + " branch(s)."
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

