#Save all Office 2016 shortcuts to a new folder on the Start Menu specifically for Windows 7 users
#$ErrorActionPreference= 'silentlycontinue'
Clear-Host


$Path = "$Env:ProgramData\Microsoft\Windows\Start` Menu\Programs"
# Create new folder in Start Menu called Office 2016
new-item "$Env:ProgramData\Microsoft\Windows\Start` Menu\Programs\Office` 2016" -type directory -force
$newdest = "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\Office` 2016"

# Get all shortcuts in Start Menu
$StartMenu = Get-ChildItem $Path -Recurse -Include *.lnk

# Wildcard match for Office 2016
$match = "*2016*"

# Loop through each shortcut looking for $match (wildcard)
ForEach ($Item in $StartMenu) {



if ($newdiritem = $Item | where-object {$_.Name -like $match}){

#Keep quote in file path
$newdiritemupdate = '"{0}"' -f $newdiritem

#copy all shortcuts that match to new folder
copy-item $newdiritem -destination $newdest -Force

#write-host to confirm paths
write-host $newdiritemupdate

#Reset variable for next loop intineration
$newdiritemupdate = ""
            }

#No action for non Office 2016 files
else{
$newdiritem = ""
}
}
