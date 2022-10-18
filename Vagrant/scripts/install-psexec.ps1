$tools = "C:\Tools"
$log = "C:\Tools\log"

Set-Alias 7zip 'C:\Program Files\7-Zip\7z.exe'

if(-not(Test-Path($log))){
    mkdir $log
}

$psexecUrl = "https://download.sysinternals.com/files/PSTools.zip"
$PSTools = "$tools\PSTools.zip"
$psDir = "$tools\PSTools"

if(-not(Test-Path($psDir))){
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing PSTools..."
    mkdir $psDir
    Invoke-WebRequest -Uri $psexecUrl -OutFile $PSTools
    7zip x -y $PSTools -o"$psDir" 
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) PSTools already installed..."
}