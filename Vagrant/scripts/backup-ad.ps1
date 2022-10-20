# Backup users, computers, groups and Organizational Units
(Get-ADUser -Filter *).samAccountName > users.txt
(Get-ADComputer -Filter *).samAccountName > computers.txt
(Get-ADGroup -Filter *).samAccountName > groups.txt
(Get-ADOrganizationalUnit -Filter *).Name > ous.txt

$usersNum = (Get-Content users.txt).Count
$computersNum = (Get-Content computers.txt).Count
$groupsNum = (Get-Content groups.txt).Count
$ouNum = (Get-Content ous.txt).Count

Write-Host "Backed up Active Directory environment"
Write-Host "Founded:"
Write-Host "$usersNum users"
Write-Host "$computersNum computers"
Write-Host "$groupsNum groups"
Write-Host "$ouNum Organizational Units"

Write-Host "Press a key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")