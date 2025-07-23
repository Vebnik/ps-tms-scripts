$config = Get-Content -Raw config.json | ConvertFrom-Json

$testContainer = $config.testContainer

try {
  $start = Get-Date

  Write-Host "[ℹ️] Run LoginTest"
  docker exec -it $testContainer /usr/bin/bash -c "cd /ps-tms-selenium-tests && mvn -X -B clean install -X -T 16 -Dtest=com.sonoma.pstms.selenium.LoginTest" | Out-File -FilePath ./logs/LoginTest.log
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline '[ℹ️] Awaiting for update license & restart TMS (press any key)';
  Write-Host -Object ('' -f [System.Console]::ReadKey().Key.ToString());

  Write-Host "[ℹ️] Run Tests"
  docker exec -it $testContainer /usr/bin/bash -c "cd /ps-tms-selenium-tests && mvn -X -B clean install '-Dtest=com.sonoma.pstms.selenium.*.**, !LoginTest' test" | Out-File -FilePath ./logs/Test.log
  Start-Sleep -Seconds 0.25

  $end = Get-Date
  $delta = New-TimeSpan -Start $start -End $end

  Write-Host "[ℹ️] Done ✅ -> See logs files for detail"
  Write-Host "[ℹ️] Elapsed time -> $delta"
}
catch {
  Write-Host "[🚫] Some error ..."
}