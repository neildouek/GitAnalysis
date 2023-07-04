clear

#$repoName = "code-examples-csharp"
#$repoSource = "https://github.com/docusign/$repoName.git"


$repoName = "MyCustomerApp"
$repoSource = "https://github.com/neildouek/$repoName.git"
#MyCustomerApp
#extremedevops
#repo-test1


$workingDir = "/Users/neildouek1/Documents/fujitsu/dev/workingdir"
$jsonChecks = "/Users/neildouek1/Documents/fujitsu/dev/GitAnalysis/checks.json"

Import-Module ./Invoke-CloneRepo.ps1
Import-Module ./Remove-Directory.ps1
Import-Module ./Invoke-Check.ps1


RemoveDirectory -Path $workingDir

$dirRepo = $workingDir+"/repo"
$dirData = $workingDir+"/data"


$repoPath = "$dirRepo/$repoName"

RemoveDirectory -Path $dirRepo
mkdir $dirRepo
mkdir $dirData

$dataFileName = $dirData + "/$repoName-data.json"


Set-Location $dirRepo


#
Write-Host "Run Checks"

# Create a parent hashtable for the repository
# Initialize a hashtable with "RepoName"
$repoData = @{
    RepoName = "repoSource"
}

# Convert to JSON and save to file
$repoData | ConvertTo-Json -Depth 3 -Compress | Set-Content -Path $dataFileName

# Read the JSON data from file
$jsonData = Get-Content -Raw -Path $jsonChecks | ConvertFrom-Json
$checkTotal =$jsonData.Count
$checkCtr = 0
# Iterate over each item in the JSON array


# Create a parent hashtable for the repository
$repoData = @{
    RepoName = "$RepoName"
}

# Convert to JSON and save to file
$repoData | ConvertTo-Json -Depth 3 -Compress | Set-Content -Path $dataFileName

$processedCtr = 0

foreach ($item in $jsonData) {
    $checkCtr = $checkCtr + 1
    $checkID = $item.CheckID
    $checkName = $item.CheckName
    $checkDescription = $item.CheckDescription
    $checkModule = $item.CheckModule
    $checkOutput = $item.CheckOutput

    if($checkName -eq "EXIT")
    {
        break
    }

    # Perform actions for each item
    Write-Host $NewLine
    Write-Host "Processing Check ${checkCtr} of ${checkTotal} :  ${checkID}: ${checkName}"
    Write-Host "--- Description: ${checkDescription}"
    Write-Host "--- Module Name ${checkModule}"
    
    #Write-Host
    # Call the Invoke-Check function


    #Set Up the result hashtable to pass around:
    $result = @{
        CheckID = $checkID
        CheckName = $checkName
        CheckDescription = $CheckDescription
        CheckModule = $checkModule
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Value = $null
        Comment = $Comment
        Success = $false
        Elapsed = $null
    }

    $params = @{
        RepoSource = $repoSource
        RepoPath = $repoPath
        DataPath = $dirData
    }

    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
   
    InvokeCheck -params $params -result $result
    $stopwatch.Stop()
    $result.Elapsed = $stopwatch.Elapsed.TotalSeconds

    # Check if $result is a hashtable
    if ($result -is [Hashtable]) {
        # Convert hashtable to a JSON string
        $result = $result | ConvertTo-Json -Depth 4
        $result = $result | ConvertFrom-Json
    }

    # Display the result
    $result

    if($null -ne $checkOutput){
        #Store as a reference file in data 
        $checkDataFileName = "$dirData/"+$checkOutput+".json"
        $result | ConvertTo-Json -Depth 4 | Set-Content $checkDataFileName
    }
    else {
        #Store in the main file  

        # Load current data
        $currentData = Get-Content -Path $dataFileName | ConvertFrom-Json

        # Add new property. Adjust this according to what properties you want to add
        $currentData | Add-Member -MemberType NoteProperty -Name $checkID -Value $result

        # Now when you call ConvertTo-Json, you won't get escape characters in the output
        $currentData | ConvertTo-Json -Depth 4 | Set-Content -Path $dataFileName
    }
    $processedCtr++    
}
Write-Host "That's all folks. Processed $processedCtr item(s)."