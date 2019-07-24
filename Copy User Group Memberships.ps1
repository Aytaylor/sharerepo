<#
.SYNOPSIS
    This script will copy Active Directly Group Memberships from a Source User to a Target User. 
    It will post in the console the Group Memberships that Target User has, but the Soure User does not.
.Description
    Run the script and it will prompt for 2 parameters: Source User and Target User. 
    After you designate the users, the script will copy any Group Memberships the Source User has 
    and the target user does not. After completing, it will post any memberships the Target User has
    that the Source User does not. 
.NOTES
    File Name     : Copy User Group Memberships.ps1
    Author        : Alex Taylor
    Updated: 11/12/2017
#>

# Script to copy group memberships from a source user to a target user.

Param ($Source, $Target)
If ($Source -ne $Null -and $Target -eq $Null)
{
    $Target = Read-Host "Target User Logon"
}
If ($Source -eq $Null)
{
    $Source = Read-Host "Source User Logon"  #Define Source User
    $Target = Read-Host "Target User Logon"  #Define Target User
}

# Retrieve group memberships.
$SourceUser = Get-ADUser $Source -Properties memberOf
$TargetUser = Get-ADUser $Target -Properties memberOf

# Hash table of source user groups.
$List = @{}

#Enumerate direct group memberships of source user.
ForEach ($SourceDN In $SourceUser.memberOf)
{
    # Add this group to hash table.
    $List.Add($SourceDN, $True)
    # Bind to group object.
    $SourceGroup = [ADSI]"LDAP://$SourceDN"
    # Check if target user is already a member of this group.
    If ($SourceGroup.IsMember("LDAP://" + $TargetUser.distinguishedName) -eq $False)
    {
        # Add the target user to this group.
        Add-ADGroupMember -Identity $SourceDN -Members $Target
    }
}

# Enumerate direct group memberships of target user.
ForEach ($TargetDN In $TargetUser.memberOf)
{
    # Check if source user is a member of this group.
    If ($List.ContainsKey($TargetDN) -eq $False)
    {
        # Source user not a member of this group.
        # Remove target user from this group.
        # UNCOMMENT TO Remove-ADGroupMember $TargetDN $Target
        Write-Host $Source " is not a member of " $TargetDN
    }
}