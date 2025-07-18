Get-Content .\logs\Test.log | Select-String "<<< FAILURE!$" | Out-File ./logs/failure.log
Get-Content .\logs\Test.log | Select-String "<<< ERROR!$" | Out-File ./logs/error.log
Get-Content .\logs\Test.log | Select-String "Test ended >>>" | Out-File ./logs/ended.log

$failure = (Get-Content .\logs\failure.log | Measure-Object).Count
$errors = (Get-Content .\logs\error.log | Measure-Object).Count
$ended = (Get-Content .\logs\ended.log | Measure-Object).Count

Write-Host "Ended: $ended | Error: $errors | Failure: $failure"