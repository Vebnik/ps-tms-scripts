param($ps_tms_dir)

$current_dir=Get-Location

if (!$ps_tms_dir) {
  Write-Host "[ERROR] Not found ps_tms_dir first arg"
}

try { 
  # seleting exist container
  Write-Host "[INFO] Deleting (if) existing container"
  docker container rm -f ps-tms-ubuntu-builder
  Start-Sleep -Seconds 0.25

  # pulling ubuntu
  Write-Host "[INFO] Pulling ubuntu ..."
  sudo docker pull ubuntu
  Start-Sleep -Seconds 0.25

  # run docker as bg tasks
  Write-Host "[INFO] Runing ps-tms-ubuntu-builder ..."
  docker run -p 3111:3111 -itd --name ps-tms-ubuntu-builder ubuntu
  Start-Sleep -Seconds 0.25

  Write-Host "[INFO] Update apt ..."
  docker exec -it ps-tms-ubuntu-builder apt update
  Start-Sleep -Seconds 0.25

  Write-Host "[INFO] Install java 21 ..."
  docker exec -it ps-tms-ubuntu-builder apt install openjdk-21-jre maven vim
  Start-Sleep -Seconds 0.25

  Write-Host "[INFO] Copying ps-tms ..."
  docker cp $ps_tms_dir ps-tms-ubuntu-builder:/
  Start-Sleep -Seconds 0.25

  Write-Host "[INFO] Building ps-tms ..."
  docker exec -it ps-tms-ubuntu-builder /usr/bin/bash -c "cd /pstms && ./build.sh"
  Start-Sleep -Seconds 0.25

  # run copy and extract ps-tms
  Write-Host "[INFO] Building ps-tms ..."
  docker exec -it ps-tms-ubuntu-builder /usr/bin/bash -c "cd /pstms && ./build.sh"
  Start-Sleep -Seconds 0.25

  # run copy and extract ps-tms
  Write-Host "[INFO] Building ps-tms ..."
  docker cp ps-tms-ubuntu-builder:/pstms/ps-tms-packer/target/ps-tms-packer-4.0.3-bin.tar.gz $current_dir/ps-tms-packer-4.0.3-bin.tar.gz
  Start-Sleep -Seconds 0.25
} catch { 
  Write-Host "[ERROR] Some error"
}
