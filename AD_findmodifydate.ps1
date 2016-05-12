# AD client tools need to be installed on local system.
# One year ago
$d = [DateTime]::Today.AddDays(-360)

# Show desktops only that have not been modified in 1 year
$olddesktops = get-adcomputer -filter 'Modified -le $d' -properties Modified | Where-Object {$_.name -like '*dt*'} | FT Name, Modified | format-table name

# Show anything that has not been modified in 1 year
$oldeverything = get-adcomputer -filter 'Modified -le $d' -properties Modified | FT Name, Modified | format-table name

 # Deleted old desktops that have not been modified in a year
 # Remove process will begin as soon as you highlight and run command
$deleteold = get-adcomputer -filter 'Modified -le $d' -properties Modified | Where-Object {$_.name -like '*dt*'} | remove-adcomputer
