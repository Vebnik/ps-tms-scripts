Write-Host "[INFO] Running ps-tms-ubuntu container ..."
docker container start ps-tms-ubuntu

Write-Host "[INFO] Running ps-tms-ubuntu ..."
docker exec -it ps-tms-ubuntu /usr/bin/bash -c "cd ./release && /usr/sbin/ps-tms/front-end-server/start_servers.sh"