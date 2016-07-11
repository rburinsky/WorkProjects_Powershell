<# Database test connectivity and query table

$datasource is the instance

DB_datareader permission needed for user running script

Change the parameters $datasource and $database in script or from command line
#>

function test-dbconnect($dataSource = “servername", $database = “database”){



 
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

# Test query of any table or view
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
Write-host "Error connecting to '$database' on '$dataSource'" -ForegroundColor Red
Write-host "The details of the error are:  '$_ '"


}
}