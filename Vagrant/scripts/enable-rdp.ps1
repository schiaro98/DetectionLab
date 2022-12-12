$usersDomain = @("domainUser1", "domainUser2", "domainUser3", "domainUser4", "vagrant")

foreach ($user in $usersDomain) {
    Add-ADGroupMember -Identity "Remote Desktop Users" -Members $user
}

net localgroup "Remote Desktop Users" "local1" /add
net localgroup "Remote Desktop Users" "local2" /add
net localgroup "Remote Desktop Users" "vagrant" /add

Write-Host "Users joined rdp group..."