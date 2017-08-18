function appcheck{

$computers_obj = @()

# Import list of machines
$Machines = "C:\computers_desktops_pilot2.txt"
$Computers = Get-Content $Machines

#Log location
$logfile="c:\objectinfo_log_adobeflash_java.txt"




foreach ($c in $computers){
   
    
    
    $test = Test-Connection -computername $c -quiet
    $system = Get-wmiobject Win32_OperatingSystem -computername $c 
    
  
    
    # Check if winrm is running
    $servicecheckwinrm = get-service -name WinRM -computername $c
  
   
   # Need to establish a connection to remote registry
   $service = Get-Service 'RemoteRegistry' -cn $c
 
     If ($service.Status -match 'Stopped') {$service.Start()}
   
   
   # Use invoke-command to connect to remote system
   # Check for Adobe Flash Active x and Java Runtime
   $program = Invoke-command -computername $c -scriptblock { Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*  |  where {$_.displayname -Like "*Adobe*" -or $_.displayname -Like "*Java*" }  | Select-Object DisplayName, DisplayVersion, InstallDate} 
   $n = 0
  
   foreach ($p in $program)
   {
    
        #Check for Adobe Flash Activex
        if ($p.displayname -like "*flash*activex*")
        {
        $adobeversion =  $program[$n]
        }
    
         #Check for Adobe Flash NPAPI
        if ($p.displayname -like "*flash*NPAPI*")
        {
        $adobeversion_n =  $program[$n]
        }
    
        #Check for Adobe Shockwave Player
        if ($p.displayname -like "*shockwave*player*")
        {
        $adobeshock =  $program[$n]
        }
        
         #Check for Adobe Acrobat Reader
        if ($p.displayname -like "*acrobat*reader*")
        {
        $adobereader =  $program[$n]
        }
        
        
        #Check for Java
        if ($p.displayname -like "*Java*Update*" -and $p.DisplayName -notmatch "Java Auto Updater")
        {
        $javaversion =  $program[$n]
        }

        #Loop through each line in the array, starting with 0
        $n = $n + 1

    }

    
    #Trim character from beginning of variables to make output more readable
    #Convert line in array to String or .substring will not work
    $adobeversion = [string]$adobeversion
    $adobeversion = $adobeversion.substring(14)
    $adobeversion_n = [string]$adobeversion_n
    $adobeversion_n = $adobeversion_n.substring(14)
    $javaversion = [string]$javaversion
    $javaversion = $javaversion.substring(14)
    $adobeshock = [string]$adobeshock
    $adobeshock = $adobeshock.substring(14)
    $adobereader = [string]$adobereader
    $adobereader = $adobereader.Substring(14)

    #Create object
    
   $obj = New-Object System.Object
   $obj | Add-member -MemberType NoteProperty -Name Computername -Value $c;
   $obj | Add-member -MemberType NoteProperty -Name OS -Value $system.converttodatetime($system.InstallDate);
   $obj | Add-member -MemberType NoteProperty -Name LastBoot -Value  $system.converttodatetime($system.LastBootupTime);
   $obj | Add-member -MemberType NoteProperty -Name Caption -Value  $system.Caption;
   $obj | Add-member -MemberType NoteProperty -Name Service_Name -Value  $servicecheckwinrm.DisplayName;
   $obj | Add-member -MemberType NoteProperty -Name Status -Value  $servicecheckwinrm.Status;
   $obj | Add-member -MemberType NoteProperty -Name AdobeFlashActivex -Value  $adobeversion;
   $obj | Add-member -MemberType NoteProperty -Name AdobeFlashNPAPI -Value  $adobeversion_n;
   $obj | Add-member -MemberType NoteProperty -Name AdobeShockwave -Value  $adobeshock;
   $obj | Add-member -MemberType NoteProperty -Name AdobeReader -Value  $adobereader;
   $obj | Add-member -MemberType NoteProperty -Name JavaVersion -Value  $javaversion;
   
   
   #Add to hash table
   $computers_obj += $obj
                          }

    
    #Send data to log
    
    Write-Output  $computers_obj
    $date = get-date
    Write-Output "------------------------------------------" | Out-File $logfile
    write-output $date | Out-File $logfile -width 240 -Append
    write-output  $computers_obj | Out-File $logfile -width 240 -Append



           }

#Run function
appcheck