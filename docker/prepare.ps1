
param($psTmsTar)

try {
  Write-Host "[ℹ️] Deleting (if) existing container"
  docker container rm -f ps-tms-ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Pulling ubuntu ..."
  docker pull ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Runing ps-tms-ubuntu ..."
  docker run -p 443:8443 -itd --name ps-tms-ubuntu ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Updating ubuntu ..."
  docker exec -it ps-tms-ubuntu apt update | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Installing deps for ubuntu ..."
  docker exec -it ps-tms-ubuntu apt install dos2unix | Out-Null
  Start-Sleep -Seconds 0.25

  docker exec -it ps-tms-ubuntu mkdir ps-tms
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Copying ps-tms archive ..."
  docker cp $psTmsTar ps-tms-ubuntu:/ps-tms-packer.tar.gz
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Extracting ps-tms archive ..."
  docker exec -it ps-tms-ubuntu tar -xzf /ps-tms-packer.tar.gz
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Execution dos2unix ..."
  docker exec -it ps-tms-ubuntu /usr/bin/bash -c "cd ./release && dos2unix ./*.sh"  | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Installing services ..."
  docker exec -it ps-tms-ubuntu chmod +x /release/install-service.sh  | Out-Null
  Start-Sleep -Seconds 0.25

  docker exec -it ps-tms-ubuntu /usr/bin/bash -c "cd ./release && ./install-service.sh"  | Out-Null
  Start-Sleep -Seconds 0.25

  docker exec -it ps-tms-ubuntu /usr/bin/bash -c "dos2unix /usr/sbin/ps-tms/**/*.sh && dos2unix /usr/sbin/ps-tms/*.sh" | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Deleting start from pstms user ..."
  docker exec -it ps-tms-ubuntu /usr/bin/bash -c "sed -i 's/sudo -u pstms //' /usr/sbin/ps-tms/front-end-server/start_servers.sh" | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Done ✅ -> Use start script for launch ps-tms"
} catch { 
  Write-Host "[🚫] Some error ..."
}