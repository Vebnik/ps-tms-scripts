ps_tms_tar=$1

# seleting exist container
docker container rm -f ps-tms-ubuntu

# pulling ubuntu
sudo docker pull ubuntu

# run docker as bg tasks
docker run -p 8443:8443 -itd --name ps-tms-ubuntu ubuntu

# run copy and extract ps-tms
docker exec -it ps-tms-ubuntu apt update
docker exec -it ps-tms-ubuntu apt install nano

docker exec -it ps-tms-ubuntu mkdir ps-tms
docker cp $ps_tms_tar ps-tms-ubuntu:/ps-tms-packer.tar.gz

docker exec -it ps-tms-ubuntu tar -xzf /ps-tms-packer.tar.gz
docker exec -it ps-tms-ubuntu chmod +x /release/install-service.sh

docker exec -it ps-tms-ubuntu /usr/bin/bash -c "cd ./release && ./install-service.sh"
docker exec -it ps-tms-ubuntu /usr/bin/bash -c "sed -i 's/sudo -u pstms //' /usr/sbin/ps-tms/front-end-server/start_servers.sh"