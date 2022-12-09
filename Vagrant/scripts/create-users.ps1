# Check for users, and if they doesn't exist, create it

# We need two local users, local1 without privileges, 
# and local2 with administrative privileges

$user1 = "local1"
$user2 = "local2"

$pass = "Password123"
$password = ConvertTo-SecureString $pass -AsPlainText -Force
 
$checkForUser1 = (Get-LocalUser).Name -Contains $user1
$checkForUser2 = (Get-LocalUser).Name -Contains $user2

if ($checkForUser1 -eq $false) { 
    Write-Host "$user1 does not exist, gonna create it..."
    New-LocalUser -Name $user1 -Description "Local user for lab purpose" -Password $password
} else { 
    Write-Host "$user1 already exist..."
}



if ($checkForUser2 -eq $false) { 
    Write-Host "$user2 does not exist, gonna create it..."
    net user $user2 $pass /add /expires:never /comment:"Local admin user for lab purpose"
    net localgroup administrators $user2 /add
} else { 
    Write-Host "$user2 already exist..."
}

Write-Host "Creation of local users completed..."