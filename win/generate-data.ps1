$db = "F:\work-pbf\ps-tms-scripts\poslogs.mv.db"
$connectString = "Provider=iSeries Access ODBC Driver;Data Source=$db;Uid=poslogs;Pwd=123;CurrentSchema=PUBLIC"
$connection = New-Object System.Data.OleDb.OleDbConnection($connectString);
$ds = New-Object "System.Data.DataSet"  

$da = New-Object System.Data.OleDb.OleDbDataAdapter($QuerySQL, $connection)

$da.Fill($ds)

Write-Host $ds.Tables[0]

# $ds.Tables[0].Rows |
#   select * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray |
#   Export-Csv "c:\Scripts\results.csv" -encoding "unicode" -notype