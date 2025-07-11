try {
  Write-Host "[ℹ️] Deleting (if) existing container"
  docker container rm -f ps-tms-selenium | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Pulling selenium/standalone-chrome ..."
  docker pull selenium/standalone-chrome | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Runing ps-tms-selenium ..."
  docker run -d `
    -p 4444:4444 `
    -p 7900:7900 `
    -e VNC_NO_PASSWORD=1 `
    -e SE_OPTS="--enable-managed-downloads true" `
    -e SE_NODE_MAX_SESSIONS=5 `
    --name ps-tms-selenium `
    --network=pstms `
    --shm-size="3g" `
    selenium/standalone-chrome | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Done ✅ -> http://localhost:4444/"
} catch { 
  Write-Host "[🚫] Some error ..."
}