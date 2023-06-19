function RemoveDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        # Remove all files and subdirectories within the directory
        If(Test-Path -Path $Path)
        {
            Get-ChildItem -Path $Path -Force -Recurse | Remove-Item -Force -Recurse

            # Verify if the directory is empty
            if ((Get-ChildItem -Path $Path).Count -eq 0) {
                Write-Host "Directory '$Path' has been emptied successfully"
            }
            else {
                Write-Host "Failed to empty the directory '$Path'"
            }            
        }
        else {
            Write-Host "Path does not exist '$Path'"
        }
    }
    catch {
        Write-Host "An error occurred while emptying the directory '$Path':"
        Write-Host $_.Exception.Message
    }
}
