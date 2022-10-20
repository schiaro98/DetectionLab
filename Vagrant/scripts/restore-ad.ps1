$users = Get-Content users.txt

foreach ($user in (Get-ADUser -Filter *).samAccountName){
    if($users.Contains($user) -eq $false){
        #Remove-ADUser -Identity $user -Confirm:$false
        Write-Host "Removed $user from Active Directory users"
    }
}

$workstations = Get-Content computers.txt

foreach ($pc in (Get-ADComputer -Filter *).samAccountName){
    if($workstations -notcontains $pc){
        #Remove-ADComputer -Identity $pc -Confirm:$false
        Write-Host "Removed $pc from Active Directory computers"
    }
}

$groups = Get-Content groups.txt

foreach ($group in (Get-ADGroup -Filter *).samAccountName){
    if($groups -notcontains $group){
        #Remove-ADGroup -Identity $group -Confirm:$false
        Write-Host "Removed $group from Active Directory groups"
    }
}

$ous = Get-Content ous.txt

foreach ($ou in (Get-ADOrganizationalUnit -Filter *).Name){
    if($ous -notcontains $ou){
        #Remove-ADOrganizationalUnit -Identity $ou -Confirm:$false
        Write-Host "Removed $ou from Active Directory Organizational Units"
    }
}

Write-Host "Cleaned Active Directory environment"