# Check for users, and if they doesn't exist, create it

# We need several domain users, domainUser1 without privileges, 
# domainUser2 with domain admins priviliges, domainUser3/4 that are domain admins 

$user1 = "domainUser1"
$user2 = "domainUser2"
$user3 = "domainUser3"
$user4 = "domainUser4"

$users = @($user1,$user2,$user3,$user4)

$pass = "Password123"
$password = ConvertTo-SecureString $pass -AsPlainText -Force
 
foreach ($user in $users) {
    if((Get-ADUser -Filter *).SamAccountName -Contains $user -eq $false){
        Write-Host "$user does not exist, gonna create it..."
        New-ADUser -Name $user -AccountPassword $password
    } else {
        Write-Host "$user already exist..."    
    }
}

Add-ADGroupMember -Identity "Domain Admins" -Members $user2, $user3, $user4
Add-ADGroupMember -Identity "Administrators" -Members $user3, $user4
Add-ADGroupMember -Identity "Schema Admins" -Members $user3, $user4
Add-ADGroupMember -Identity "Enterprise Admins" -Members $user3, $user4
Add-ADGroupMember -Identity "Group Policy Creator Owners" -Members $user3, $user4
