$config = Get-Content -Raw config.json | ConvertFrom-Json

$seleniumContainer = $config.seleniumContainer
$network = $config.network

try {
  Write-Host "[ℹ️] Deleting (if) existing container"
  docker container rm -f $seleniumContainer | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Pulling selenium/standalone-chrome ..."
  docker pull selenium/standalone-chrome | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Runing $seleniumContainer ..."
  docker run -d `
    -p 4444:4444 `
    -p 7900:7900 `
    -e VNC_NO_PASSWORD=1 `
    -e SE_OPTS="--enable-managed-downloads true" `
    -e SE_NODE_MAX_SESSIONS=5 `
    --name $seleniumContainer `
    --network=$network `
    --shm-size="3g" `
    selenium/standalone-chrome | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Done ✅ -> http://localhost:4444/"
} catch { 
  Write-Host "[🚫] Some error ..."
}