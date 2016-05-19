# Get Start Time
$startDTM = (Get-Date)

# Database info
$dataSource = “SERVERNAME"
$database = “DB_NAME”

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


Write-host "Running query..."

#SQL query for specific programs

$query = "
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT B.Name0,
      A.GroupID,
      A.RevisionID,
      A.AgentID,
      A.TimeStamp,
      A.DisplayName0,
      A.InstallDate0,
      A.ProdID0,
      A.Publisher0,
      A.Version0,
	  B.Username0
  FROM v_GS_ADD_REMOVE_PROGRAMS A, v_GS_COMPUTER_SYSTEM B

  WHERE
A.ResourceID = B.ResourceID and

(
DisplayName0 LIKE 'Microsoft Visio%'
OR
DisplayName0 LIKE 'Microsoft Office Visio%'
OR
DisplayName0 LIKE 'Microsoft Project%'
OR
DisplayName0 LIKE 'Microsoft Office Project%'
OR
DisplayName0 LIKE 'Adobe Acrobat%'

)
"
$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteReader()

$table = new-object “System.Data.DataTable”
$table.Load($result)
$Count = $table.Rows.Count



#File creation with data with date stamp
$Date = Get-Date -Format HH-mm--dd-MMM-yy
$Path = "C:\temp\software_updated_raw_$Date.csv"

#$table | Export-Csv -Path $Path

# Double filter data from query, remove lab* and remove Adobe Reader
$table | where-object{$_.Name0 -notlike 'lab*'} | where-object{$_.DisplayName0 -notlike 'Adobe Acrobat Reader*'}| sort-object -Property name0 |Export-Csv -Path $Path   #Use for testing at end of pipeFormat-Table -AutoSize
Invoke-Item -Path $Path

# Close the connection
$connection.Close()

# Get End Time
$endDTM = (Get-Date)

# Echo Time elapsed
"Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds"

Import-CSV "C:\temp\software_updated_raw_$Date.csv" | Group-Object name0 | foreach-object { $_.group | sort-object Timestamp | select -last 1} | Export-Csv C:\temp\software_updated_$Date.csv
