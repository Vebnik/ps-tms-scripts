
param($ps_tms_tar)

if (!$ps_tms_tar) {
  Write-Host "[ERROR] Not found ps_tms_tar first arg"
}

# seleting exist container
Write-Host "[INFO] Deleting (if) existing container"
docker container rm -f ps-tms-ubuntu
Start-Sleep -Seconds 0.25

# pulling ubuntu
Write-Host "[INFO] Pulling ubuntu ..."
sudo docker pull ubuntu
Start-Sleep -Seconds 0.25

# run docker as bg tasks
Write-Host "[INFO] Runing ps-tms-ubuntu ..."
docker run -p 443:8443 -itd --name ps-tms-ubuntu ubuntu
Start-Sleep -Seconds 0.25

# run copy and extract ps-tms
Write-Host "[INFO] Copying and extracting ps-tms ..."
docker exec -it ps-tms-ubuntu apt update
Start-Sleep -Seconds 0.25

docker exec -it ps-tms-ubuntu mkdir ps-tms
Start-Sleep -Seconds 0.25
docker cp $ps_tms_tar ps-tms-ubuntu:/ps-tms-packer.tar.gz
Start-Sleep -Seconds 0.25

docker exec -it ps-tms-ubuntu tar -xzf /ps-tms-packer.tar.gz
Start-Sleep -Seconds 0.25
docker exec -it ps-tms-ubuntu chmod +x /release/install-service.sh
Start-Sleep -Seconds 0.25

docker exec -it ps-tms-ubuntu /usr/bin/bash -c "cd ./release && ./install-service.sh"
Start-Sleep -Seconds 0.25
docker exec -it ps-tms-ubuntu /usr/bin/bash -c "sed -i 's/sudo -u pstms //' /usr/sbin/ps-tms/front-end-server/start_servers.sh"
Start-Sleep -Seconds 0.25