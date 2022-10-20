# Check for other users than standard, and if they exist, delete it

$users = Get-Content default-users.txt

foreach ($user in (Get-ADUser -Filter *).samAccountName){
    if($users.Contains($user) -eq $false){
        Remove-ADUser -Identity $user -Confirm:$false
        Write-Host "Removed $user from Active Directory users"
    }
}

#TODO remove from dns records?

$workstations = Get-Content default-workstations.txt

foreach ($pc in (Get-ADComputer -Filter *).samAccountName){
    if($workstations -notcontains $pc){
        Remove-ADComputer -Identity $pc -Confirm:$false
        Write-Host "Removed $pc from Active Directory computers"
    }
}

$groups = Get-Content default-groups.txt

foreach ($group in (Get-ADGroup -Filter *).samAccountName){
    if($groups -notcontains $group){
        Remove-ADGroup -Identity $group -Confirm:$false
        Write-Host "Removed $group from Active Directory groups"
    }
}

$ous = Get-Content default-ous.txt

foreach ($ou in (Get-ADOrganizationalUnit -Filter *)){
    if($ous -notcontains $ou.name){
        $distName = $ou.DistinguishedName
        if(( $distName -split ",").Count -eq 3){
            Get-ADOrganizationalUnit -Identity $distName | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false
            Remove-ADOrganizationalUnit -Identity $distName -Recursive -Confirm:$false
            Write-Host "Removed $ou from Active Directory Organizational Units"
        }
    }
}

Write-Host "Cleaned Active Directory environment"