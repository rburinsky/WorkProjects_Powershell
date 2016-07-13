
<#
.Synopsis
GUI that runs commonly used SCCM commands to check on the deployment status of advertisements.


.Description
The current functions:

get-packagedetail: Does not require SCCM module to be load. It  provides detailed information
                   on each advertisement per system
Check-Deploystats: Overview of Success/Fail rate of a SCCM advertisement, per DeploymentID

Lookup-Deployid: Look up deploymentid by name and wildcard

test-dbconnect: Check connection to db



#>

function comboboxrun {

 $ErrorActionPreference= 'silentlycontinue'

###Nested function advertisement detail per system
# Does not require SCCM Configuration Module

<# Database test connectivity and query table

$datasource is the instance

DB_datareader permission needed for user running script

Change the parameters $datasource and $database in script or from command line
#>




function test-dbconnect($dataSource = “server", $database = “db”){



 
# Open a connection
try{
cls
Write-host "Opening a connection to '$database' on '$dataSource'"
#Using windows authentication, or..
$connectionString = “Server=$dataSource;Database=$database;Integrated Security=SSPI;”
# Using SQL authentication
#$connectionString = "Server=$dataSource;Database=$database;uid=ConfigMgrDB_Read;pwd=Pa$$w0rd;Integrated Security=false"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
Write-host "Successfully conencted to '$database'" -ForegroundColor Green

# test query of any table or view
Write-host "Now test a query. use a known SCCM view" -ForegroundColor Green
$Query = "select * from v_HS_System"
$command = $connection.CreateCommand()
$command.CommandText = $Query
$result = $command.ExecuteReader()

#Store results in table
$table = new-object "system.data.datatable"
$table.load($result)

#Displaying the column names I want to see
$table | select-object -property name0, domain0, timestamp | format-table -AutoSize



$connection.close



#Catch the error
}catch{
Write-host "Error connedcting to '$database' on '$dataSource'" -ForegroundColor Red
Write-host "The details of the error are:  '$_ '"


}
}



function get-packagedetail {

<#
Look up advertisement detail
 
#>
 


[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$deploy = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a SCCM Deployment ID", "PS: SCCM2012", "UOBXXXXX") 

$CSV = "No" # Output to CSV, Yes or No
$Grid = "Yes" # Out-Gridview, Yes or No
# Get Start Time
$startDTM = (Get-Date)
 
# Database info
$dataSource = “server"
$database = “db”
 
# Open a connection
cls
Write-host "Opening a connection to '$database' on '$dataSource'"
#Using windows authentication, or..
$connectionString = “Server=$dataSource;Database=$database;Integrated Security=SSPI;”
# Using SQL authentication
#$connectionString = "Server=$dataSource;Database=$database;uid=ConfigMgrDB_Read;pwd=Pa$$w0rd;Integrated Security=false"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
 
# Getting Package / TS deployment status
Write-host "Running query..."
 
$query = "
select PackageName as 'Package / Task Sequence',ai.AdvertisementID as 'DeploymentID',ai.CollectionName, Name0 as 'Computer Name', User_Name0 as 'User Name', LastAcceptanceMessageIDName, LastAcceptanceStateName, LastAcceptanceStatusTime, LastStatusMessageIDName, LastStateName, LastStatusTime, LastExecutionResult
from v_ClientAdvertisementStatus cas
inner join v_R_System sys on sys.ResourceID=cas.ResourceID
inner join v_AdvertisementInfo ai on ai.AdvertisementID=cas.AdvertisementID
where AI.AdvertisementID = '$deploy' and LastStatusTime is not null ORDER BY LastStatusTime Desc
"
$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteReader()
 
$table = new-object “System.Data.DataTable”
$table.Load($result)
$Count = $table.Rows.Count
 
if ($CSV -eq "Yes")
{
$Date = Get-Date -Format HH-mm--dd-MMM-yy
$Path = "C:\Script_Files\SQLQuery-$Date.csv"
$table | Export-Csv -Path $Path
Invoke-Item -Path $Path
}
If ($Grid -eq "Yes")
{
$table | Out-GridView -Title "Deployment Status of '$Name' ($count machines)"
}
# Close the connection
$connection.Close()
 
# Get End Time
$endDTM = (Get-Date)
 
# Echo Time elapsed
"Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"


read-host "Click Enter to Exit"
}






######Nested function 1



function Check-Deploystats {

Load SCCM connection for powershell and switch to drive

cd "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin"
import-module .\ConfigurationManager.psd1 -verbose

CD UOB:

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$deploy = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a SCCM Deployment ID", "PS: SCCM2012", "UOBXXXXX") 

# All statuses for the package
get-cmpackagedeploymentstatus -deploymentid $deploy | out-gridview

# To check a particular status
#get-cmpackagedeploymentstatus -deploymentid $deploy -status success | out-gridview

read-host "Click Enter to Exit"

}


####### Nested function 2


function Lookup-Deployid  {

cd "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin"
import-module .\ConfigurationManager.psd1 -verbose

CD UOB:

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$deployname = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a Package to Lookup", "PS: SCCM2012", "*Appname*")

get-cmpackagedeploymentstatus -name $deployname | select-object -property summarizationtime, programname, packagename, collectionname, deploymentid | out-gridview
#get-cmpackagedeploymentstatus -name $deployname | out-gridview

read-host "Click Enter to Exit"

}





##GUI Form

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "SCCM Options"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objListBox.SelectedItem;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$global:x=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "SCCM Options:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

[void] $objListBox.Items.Add("Lookup-Deployid")
[void] $objListBox.Items.Add("Check-Deploystats")
[void] $objListBox.Items.Add("Get-Packagedetail")
[void] $objListBox.Items.Add("test-dbconnect")
#[void] $objListBox.Items.Add("NA")
#[void] $objListBox.Items.Add("NA")
#[void] $objListBox.Items.Add("NA")

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

& $X


}

# Run combo box when script is initialized
comboboxrun
