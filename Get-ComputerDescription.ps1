<#
.SYNOPSIS
    This script will retrieve descriptions from a list of computers.
.DESCRIPTION
    This script will take a list of computers and retrieve their respective descriptions. It will prompt to enter a computer
    name or you can use a path to a file that contains a list. Do not include quotations.
.NOTES
    File Name     : Get-ComputerDescriptions.ps1
    Author        : Alex Taylor aytaylor@crutchfield.com
.EXAMPLE
    Get-ComputerDescription.ps1 -UserFile c:\PClist.txt
#>

Param(
    [Parameter(Mandatory=$true,Position=1)]
    [string]$computers
    )

#Check if $computers exists
If (Test-Path $computers)
{
    $PCs = Get-Content $computers

    foreach ($Comp in $PCs)
    {
        get-adcomputer $Comp -properties description | select-object name, description | ft -HideTableHeaders | Out-file .\Results.txt -Append
    }
}
Else
{
    Write-Host $computers" does not exist"
    exit
}

Start-Process Notepad .\Results.txt