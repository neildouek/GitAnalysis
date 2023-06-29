clear

$repoName = "MyCustomerApp"
$repoSource = "https://github.com/neildouek/$repoName.git"
$workingDir = "/Users/neildouek1/Documents/fujitsu/dev/workingdir"
$jsonChecks = "/Users/neildouek1/Documents/fujitsu/dev/GitAnalysis/checks.json"

$RepoPath = "$workingDir/repo/$repoName"

git clone $repoSource $RepoPath

$DataPath = "$workingDir/data/"

Set-Location $DataPath



if (Get-Command brew -ErrorAction SilentlyContinue) {
    Write-Host "cloc is installed"

    # Make sure path is absolute
    $repoPath = Resolve-Path $repoPath

    # LOC Calculation
    Write-Host "Calculating Lines of Code..."
    cloc $RepoPath --xml --out=cloc.xml


} else {
    Write-Host "cloc is not installed"
}


 exit