# Purpose: Install packages required for Hashcat, Rubeus and OpenCl.

$tools = "C:\Tools"
$log = "C:\Tools\log"
$reg = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"

Set-Alias 7zip 'C:\Program Files\7-Zip\7z.exe'

if(-not(Test-Path($log))){
    mkdir $log
}

# Scarico una wordlist dalla repo
$wordlistPath = "$tools\wordlist.txt"

if(-not(Test-Path($wordlistPath))){
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Wordlist..."
    $wordlist = "https://raw.githubusercontent.com/schiaro98/DetectionLab/master/wordlist.txt"
    Invoke-WebRequest -Uri $wordlist -OutFile $wordlistPath
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Wordlist already existing, continuing..."
}

$openclName = "Intel"
$isOpenClInstalled = (Get-ItemProperty $reg | Where { $_.DisplayName -like $openclName }) -ne $null

if(-not($isOpenClInstalled)){
    $opencl = "https://registrationcenter-download.intel.com/akdlm/irc_nas/vcp/13794/opencl_runtime_18.1_x64_setup.msi"

    $openclFile = "$tools\opencl.msi"
    $openclLog = "$log\openclInstallation.log"

    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading opencl..."

    Invoke-WebRequest -Uri $opencl -OutFile $openclFile

    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i $openclFile /quiet /qn /norestart /log $openclLog" -wait
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) OpenCl is already installed, continuing..."
}

$hashcatFile = "$tools\hashcat.7z"

if(-not(Test-Path($hashcatFile))){
    $hashcat = "https://hashcat.net/files/hashcat-6.2.6.7z"
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading hashcat..."

    Invoke-WebRequest -Uri $hashcat -OutFile $hashcatFile

    7zip x -y $hashcatFile -o"$tools"
    Set-Alias hashcat "$tools\hashcat-6.2.6\hashcat.exe"
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Hashcat is already installed, continuing..."
}


$rubeus = "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe"
$rubeusFile = "$tools\Rubeus.exe"

if(-not(Test-Path($rubeusFile))){
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading rubeus..."
    Invoke-WebRequest -Uri $rubeus -OutFile $rubeusFile
    Set-Alias rubeus $rubeusFile
}   

# DOwnload SecList repo with thousand of password lists, it's more than 2 Gb, so disabled by default
# $passwordList = "https://github.com/danielmiessler/SecLists/tree/master/Passwords"

#if(-not(Test-Path("$tools\SecLists"))){
#    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Download SecLists passwords..."
#    git clone $passwordList
#} else {
#        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Passwords already downloaded, continuing..."
#}

# Remove unused file

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Cleaning useless files, archive and installer"
if (Test-Path "$tools\hashcat.7z") {Remove-Item -Path "$tools\hashcat.7z"}
if (Test-Path "$tools\opencl.msi") {Remove-Item -Path "$tools\opencl.msi"}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Hashcat install finished..."