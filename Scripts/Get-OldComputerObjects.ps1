<#
.SYNOPSIS
    This script will retrieve a list of computer objects in Active Directory that has had no logon activity for at least 90 days.
    The list is exported to a CSV file. 
.NOTES
    Author        : Alex Taylor - aytaylor@crutchfield.com
    Updated: 11/12/2017
#>

$domain = "crutchfield.ad.crutchfield.com"  
$DaysInactive = 90  
$time = (Get-Date).Adddays(-($DaysInactive)) 
  
# Get all AD computers with lastLogonTimestamp less than our time 
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | 
  
# Output hostname and lastLogonTimestamp into CSV 
select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv OLD_Computer.csv -notypeinformation