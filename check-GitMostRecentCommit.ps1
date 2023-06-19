

function check-GitMostRecentCommit {
    param (        
        [Parameter(Mandatory = $true)]
        [string]$RepoPath,
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )
 

    try {
        Set-Location $RepoPath        

        # Initialize a hashtable to store the most recent commit and branch
        $mostRecentCommit = @{
            Date = [DateTime]::MinValue
            SHA = ""
            Branch = ""
        }

        # Get the list of all branches
        $branches = git branch --format "%(refname:short)"

        # Loop through each branch and get the latest commit
        foreach ($branchName in $branches) {
            # Get the SHA and date of the latest commit on this branch
            $commitInfo = git log -1 --pretty="%h %ad" --date=iso --decorate=short $branchName

            # Split the string into parts
            $parts = $commitInfo -split '[ T]'

            # Parse the date and time
            $date = [DateTime]::ParseExact("$($parts[1])T$($parts[2])", "yyyy-MM-ddTHH:mm:ss", $null)

            # Check if this commit is more recent than the current most recent commit
            if ($date -gt $mostRecentCommit.Date) {
                # Update the most recent commit
                $mostRecentCommit.Date = $date
                $mostRecentCommit.SHA = $parts[0]
                $mostRecentCommit.Branch = $branchName
            }
        }



        $Date = $mostRecentCommit.Date
        $Span = New-TimeSpan -Start $Date -End (Get-Date)
        $Days = $Span.Days
        $Hours = $Span.Hours
        $Minutes = $Span.Minutes

        if ($Days -eq 0) {
            if ($Hours -eq 0) {
                if ($Minutes -eq 0) {
                    $activity = "Less than a minute ago"
                }
                else {
                    $activity = "$Minutes minute(s) ago"
                }
            }
            else {
                $activity = "$Hours hour(s) ago"
            }
        }
        elseif ($Days -lt 7) {
            $activity = "$Days day(s) ago"
        }
        elseif ($Days -lt 30) {
            $Weeks = [math]::Floor($Days / 7)
            if ($Weeks -eq 1) {
                $activity = "1 week ago"
            }
            else {
                $activity = "$Weeks weeks ago"
            }
        }
        elseif ($Days -lt 365) {
            if ($Days -lt 90) {
                $activity = "3 months ago"
            }
            elseif ($Days -lt 180) {
                $activity = "6 months ago"
            }
            else {
                $Months = [math]::Floor($Days / 30)
                if ($Months -eq 1) {
                    $activity = "1 month ago"
                }
                else {
                    $activity = "$Months months ago"
                }
            }
        }
        else {
            $Years = [math]::Floor($Days / 365)
            if ($Years -eq 1) {
                $activity = "1 year ago"
            }
            else {
                $activity = "$Years years ago"
            }
        }
        $comment = "The most recent commit is on branch $($mostRecentCommit.Branch) $activity"




        $result.Value = $mostRecentCommit
        $result.Success = $true
        $result.Comment = $comment

    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}




