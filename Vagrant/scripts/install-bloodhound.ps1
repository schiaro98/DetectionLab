# Purpose: Install packages required from Bloodhound (Java and Neo4j).
# Creare cartella log e collector
$temp = "C:\Tools\"
$log = "C:\Tools\log"

if(-not(Test-Path($log))){
    mkdir "$temp\log"
}

$reg = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"

$java = "Microsoft Build of OpenJDK with Hotspot 11.0.16.1+1 (x64)"
$isJavaInstalled = (Get-ItemProperty $reg | Where { $_.DisplayName -eq $java }) -ne $null

$sevenZipName = "7-Zip 22.01 (x64 edition)"
$isZipInstalled = (Get-ItemProperty $reg | Where { $_.DisplayName -eq $sevenZipName }) -ne $null

# Install 7Zip if it's not already installed

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if 7Zip is already installed"

if($isZipInstalled){
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) 7Zip is already installed, continuing"
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) 7Zip is not installed, going to install it now"

    $sevenZipUrl = "https://www.7-zip.org/a/7z2201-x64.msi"
    $sevenZipMsi = "$temp\7zip.msi"
    $sevenZipLog = "$log\7zip.log"

    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipMsi
    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i $sevenZipMsi /quiet /qn /norestart /log $sevenZipLog" -wait

    $isZipInstalled = (Get-ItemProperty $reg | Where { $_.DisplayName -eq $sevenZipName }) -ne $null
    if(-Not $isZipInstalled){
        Throw "Unable to install 7Zip, aborting..."
    } else {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) 7Zip correctly installed"        
    }
}

Set-Alias 7zip 'C:\Program Files\7-Zip\7z.exe'

# Install Java Jdk 11 if not already installed

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if Java JDK 11 is already installed"

If($isJavaInstalled) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) '$java' Is already installed, continuing";
} 
else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Java 11 Jdk is not installed yet, going to install it now"

    $jdkUrl = "https://aka.ms/download-jdk/microsoft-jdk-11.0.16.1-windows-x64.msi"
    $jdkPath = "$temp\jdk.msi"
    $jdkLogFile = "$log\jdk_install.log"

    Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkPath

    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i $jdkPath /quiet /qn /norestart /log $jdkLogFile" -wait
    
    $isJavaInstalled = (Get-ItemProperty $reg | Where { $_.DisplayName -eq $java }) -ne $null
    if  (-Not $isJavaInstalled){
        Throw "Unable to install Java, aborting..."
    } else {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Java JDK correctly installed"
    }
}

# Install neo4j if not already installed
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if Neo4j is already installed"
$neo4bat = "$temp\neo4j\neo4j-community-4.4.11\bin\"

if(-not(Test-Path $neo4bat)){
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Neo4j is not installed yet, going to install it now"

    $neo4Url = "https://dist.neo4j.org/neo4j-community-4.4.11-windows.zip"
    $neo4Path = "$temp\neo4j.zip"
    $neo4FolderPath = "$temp\neo4j"
    $neo4LogFile = "$log\neo4j_install.log"

    Invoke-WebRequest -Uri $neo4Url -OutFile $neo4Path # Download Neo4j Community zip
    Expand-Archive $neo4Path -DestinationPath $neo4FolderPath # Extracting archive

    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloaded Neo4j zip"
    cd $neo4bat 
    .\neo4j.bat install-service # Installing neo4j from his .bat installer

    if(-not(Test-Path $neo4bat)){
        Throw "Unable to install Neo4j, aborting..."
    } else {
        net start neo4j
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Neo4J correctly installed"
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) You can reach Neo4J console at this link:"
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) http://localhost:7474/"
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Remember to change the password"
        
    }
    
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Neo4j already installed, continuing" 
}

#Install bloodhound if not already installed
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if Bloodhound is already installed"
$blFolderPath = "$temp\BloodHound-win32-x64"

if(-not(Test-Path $blFolderPath)){
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Bloodhound is not installed yet, going to install it now"

    $blUrl = "https://github.com/BloodHoundAD/BloodHound/releases/download/4.2.0/BloodHound-win32-x64.zip"
    $blPath = "$temp\bloodhound.zip"
    
    Invoke-WebRequest -Uri $blUrl -OutFile $blPath
    
    7zip x -y $blPath -o"$temp"
    
    if(-not(Test-Path $blFolderPath)){
        Throw "Unable to install BloodHound, aborting..."
    } else {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) BloodHound correctly installed"
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Run BloodHound at $blFolderPath" 
    }
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Bloodhound already installed" 
}  

# Use Bloodhound default collector

$preInstalledCollector = "$blFolderPath\resources\app\Collectors\"
$collectorResult = "$temp\collector"

if(-not(Test-Path $collectorResult)){

    mkdir $collectorResult

    cd $preInstalledCollector

    .\sharphound.exe -c DCOnly --LdapUsername 'vagrant' --LdapPassword 'vagrant' --Domain windomain.local --OutputDirectory $collectorResult
    
    7zip x -y "$collectorResult\*.zip" -o"$collectorResult"

    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Results of the domain scan are available at: "
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $collectorResult"
} else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Sharphound already exisiting"    
}

# Clean all unused downloaded archive and installer
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Cleaning useless files, archive and installer"
if (Test-Path "$temp\7zip.msi") { Remove-Item -Path "$temp\7zip.msi"}
if (Test-Path "$temp\jdk.msi") {Remove-Item -Path "$temp\jdk.msi"}
if (Test-Path "$temp\bloodhound.zip") {Remove-Item -Path "$temp\bloodhound.zip"}
if (Test-Path "$temp\neo4j.zip") {Remove-Item -Path "$temp\neo4j.zip"}
if (Test-Path "$collectorResult") {Remove-Item -Path "$collectorResult\*.zip"}

# All work is done !
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) BloodHound installing finished"

