
Write-Host "[ℹ️] Checking screens directory ... "
if (Test-Path screens) {
  Write-Host "[ℹ️] Directory exists, deleting ..."
  Remove-Item -Force -Recurse -Confirm ./screens
} else {
  Write-Host "Directory not found"
}
Start-Sleep -Seconds 0.25

Write-Host -NoNewline "[ℹ️] Copying screens ... "
docker cp "ps-tms-test:/ps-tms-selenium-tests/target/screenshots/screens" "./screens"