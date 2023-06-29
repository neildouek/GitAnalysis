# Function to perform a check from an external script and return the result
function InvokeCheck {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )

    
    try {
       

        $moduleName = $result.CheckModule
        $functionName = $result.CheckModule
      

        $scriptPath = "$PSScriptRoot/$moduleName.ps1"

        #Load the script
        Write-Host("Load Module $scriptPath")
        . $scriptPath

      
        #Execute the funciton
        Write-Host("Execute Function $functionName")
        & $functionName $params $result
        
       
        
    }
    catch {
        $result.Score = 0
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

