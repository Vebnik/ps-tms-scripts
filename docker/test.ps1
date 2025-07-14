try {
  $start = Get-Date

  Write-Host -NoNewline "[ℹ️] Run LoginTest"
  docker exec -it ps-tms-test /usr/bin/bash -c "cd /ps-tms-selenium-tests && mvn install -T 16 -Dtest=com.sonoma.pstms.selenium.LoginTest" | Out-File -FilePath ./logs/LoginTest.log
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline '[ℹ️] Awaiting for update license & restart TMS (press any key)';
  Write-Host -Object ('' -f [System.Console]::ReadKey().Key.ToString());

  Write-Host -NoNewline "[ℹ️] Run Tests"
  docker exec -it ps-tms-test /usr/bin/bash -c "cd /ps-tms-selenium-tests && mvn install -T 16" | Out-File -FilePath ./logs/Test.log
  Start-Sleep -Seconds 0.25

  $end = Get-Date
  $delta = New-TimeSpan -Start $start -End $end

  Write-Host "[ℹ️] Done ✅ -> See logs files for detail"
  Write-Host "[ℹ️] Elapsed time -> $delta"
}
catch { 
  Write-Host "[🚫] Some error ..."
}