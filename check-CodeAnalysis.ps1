function check-CodeAnalysis {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$params, 
        [Parameter(Mandatory = $true)]
        [hashtable]$result
    )
   
    try {

        if (Get-Command cloc -ErrorAction SilentlyContinue) {
            Write-Host "cloc is installed"
        
            # Make sure path is absolute
            $repoPath = Resolve-Path $params.RepoPath
            $clocDataPath = $params.DataPath+"/cloc.xml"
           
        
            # LOC Calculation
            Write-Host "Calculating Lines of Code..."
            cloc $RepoPath --xml --out=$clocDataPath
            $result.Value = "cloc.xml"
            $result.Comment = "See contents of cloc.xml for more information"
            $result.Success = $true
        
        } else {           
            throw "cloc is not installed"
        }

        #Start SonarQube
        #& "/opt/homebrew/opt/sonarqube/bin/sonar" console
        
        Set-Location $repoPath

        $ComplexityAnalyzer = "/Users/neildouek1/Documents/fujitsu/dev/CodeAnalyzer/ComplexityAnalyzer/bin/Debug/net7.0/"
        
    
        Set-Location $ComplexityAnalyzer

        dotnet "ComplexityAnalyzer.dll" $repoPath

        $ComplexityAnalyzer

        <# 
        Write-Output "Begin SonsarQube here:  $repoPath"
        dotnet sonarscanner begin /k:"MyCustomerApp" /d:sonar.host.url="http://localhost:9000"  /d:sonar.token="sqp_866f013dabf0f7e5f46ef3da91700df6754f5856"
        dotnet build
        dotnet sonarscanner end /d:sonar.token="sqp_866f013dabf0f7e5f46ef3da91700df6754f5856"
        Write-Output "SonsarQube finished" #>

        #Stop SonarQube             
        #& "/opt/homebrew/opt/sonarqube/bin/sonar" stop
               
        
    }
    catch {
        $result.Success = $false
        $result.Comment = "Error: $($_.Exception.Message)"
    }

    return $result
}

