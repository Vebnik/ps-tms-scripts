Write-Host "Selected ⏬"
Write-Host "Rebuild    (1)"
Write-Host "Delete     (2)"
Write-Host "Test       (3)"
Write-Host "Run exist  (4)"
Write-Host "Clean      (5)"
$selectedMenu = Read-Host "Menu"

Clear-Host
Start-Sleep -Seconds 1

$config = Get-Content -Raw config.json | ConvertFrom-Json

$pstmsDir = $config.pstmsDir
$snapshotSuffix = $config.snapshotSuffix
$buildContainer = $config.buildContainer
$runContainer = $config.runContainer
$network = $config.network

$currentDir = (Get-Location).Path

function GetContainer {
  param (
    [string]$containerName
  )

  try {
    $container = docker inspect $containerName | ConvertFrom-Json

    if (!$container) {
      return $false
    }

    Write-Host "[ℹ️] Finded container: " $container.Id

    return $true
  }
  catch {
    return $false
  }
}

function CheckExistNetwork {
  param (
    [string]$networkName
  )

  try {
    $network = docker network inspect $networkName | ConvertFrom-Json

    if (!$network) {
      docker network create $networkName

      $network = docker network inspect $networkName | ConvertFrom-Json
      Write-Host "[ℹ️] Created network: " $network.Id

      return
    }

    Write-Host "[ℹ️] Finded network: " $network.Id
    return
  }
  catch {
    Write-Host "[🚫] Some error ..."
  }
}

function CheckExistLogs {
  Write-Host -NoNewline "[ℹ️] Creating logs directory ... "
  if (Test-Path logs) {
    Write-Host "Directory exists"
  }
  else {
    mkdir logs
    Write-Host "Directory created"
  }
  Start-Sleep -Seconds 0.25
}

function Build {
  $ifExist = GetContainer $buildContainer
  
  if (!$ifExist) {
    # prepare
    CheckExistNetwork $network
    CheckExistLogs
  
    # pulling ubuntu
    Write-Host "[ℹ️] Pulling ubuntu ..."
    docker pull ubuntu | Out-Null
    Start-Sleep -Seconds 0.25
  
    # run docker as bg tasks
    Write-Host "[ℹ️] Runing $buildContainer ..."
    docker run -itd --name $buildContainer ubuntu
    Start-Sleep -Seconds 0.25
  
    Write-Host -NoNewline "[ℹ️] Setting timezone -> "
    docker exec -it $buildContainer /usr/bin/bash -c "echo UTC > /etc/timezone"
    docker exec -it $buildContainer /usr/bin/bash -c "cat /etc/timezone"
    Start-Sleep -Seconds 0.25
  
    Write-Host "[ℹ️] Update apt ..."
    docker exec -it $buildContainer apt update | Out-Null
    Start-Sleep -Seconds 0.25
  
    Write-Host "[ℹ️] Install java 21 ..."
    docker exec -it $buildContainer apt install -y openjdk-21-jre vim dos2unix | Out-Null
    Start-Sleep -Seconds 0.25
  }
  else {
    Write-Host -NoNewline "[ℹ️] Runing exist $buildContainer ..."
    docker start $buildContainer
    Start-Sleep -Seconds 0.25  
  
    Write-Host "[ℹ️] Deleting exist ps-tms ..."
    docker exec -it $buildContainer /usr/bin/bash -c "rm -r /pstms"
    Start-Sleep -Seconds 0.25  
  }
  
  Write-Host -NoNewline "[ℹ️] Copying ps-tms ..."
  docker cp $psTmsDir ${buildContainer}:/
  Start-Sleep -Seconds 0.25
  
  Write-Host "[ℹ️] Execution dos2unix ..."
  docker exec -it $buildContainer /usr/bin/bash -c "cd /pstms && dos2unix ./mvn/bin/* && dos2unix ./mvn/bin/* && dos2unix ./**/*/*.sh &&  dos2unix ./*.sh" | Out-Null
  Start-Sleep -Seconds 0.25
  docker exec -it $buildContainer /usr/bin/bash -c "cd /pstms && sed -i 's/$\VERSION/$snapshotSuffix/' ./build.sh" | Out-Null
  Start-Sleep -Seconds 0.25

  
  Write-Host "[ℹ️] Building ps-tms ..."
  docker exec -it $buildContainer /usr/bin/bash -c "cd /pstms && ./build.sh" | Out-File -FilePath ./logs/build-logs.log
  Start-Sleep -Seconds 0.25
  
  Write-Host -NoNewline "[ℹ️] Copying ps-tms-packer ..."
  docker cp ${buildContainer}:/pstms/ps-tms-packer/target/ps-tms-packer-${snapshotSuffix}-bin.tar.gz $currentDir/ps-tms-packer-${snapshotSuffix}-bin.tar.gz
  Start-Sleep -Seconds 0.25
  
  Write-Host "[ℹ️] Done build ✅"
}

function Prepare {
  $ifExist = GetContainer $runContainer

  if ($ifExist) {
    Write-Host "[ℹ️] Deleting existing container"
    docker container rm -f $runContainer | Out-Null
    Start-Sleep -Seconds 0.25
  }

  Write-Host "[ℹ️] Pulling ubuntu ..."
  docker pull ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Runing $runContainer ..."
  docker run -p 443:8443 -p 3000:3000 -p 900:9000 -p 800:8000 -itd --network=$network --name $runContainer ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Updating ubuntu ..."
  docker exec -it $runContainer apt update | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Installing deps for ubuntu ..."
  docker exec -it $runContainer apt install dos2unix | Out-Null
  Start-Sleep -Seconds 0.25

  docker exec -it $runContainer mkdir ps-tms
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Copying ps-tms archive ..."
  docker cp $currentDir/ps-tms-packer-${snapshotSuffix}-bin.tar.gz ${runContainer}:/ps-tms-packer.tar.gz
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Extracting ps-tms archive ..."
  docker exec -it $runContainer tar -xzf /ps-tms-packer.tar.gz
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Execution dos2unix ..."
  docker exec -it $runContainer /usr/bin/bash -c "cd ./release && dos2unix ./*.sh"  | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Installing services ..."
  docker exec -it $runContainer chmod +x /release/install-service.sh  | Out-Null
  Start-Sleep -Seconds 0.25

  docker exec -it $runContainer /usr/bin/bash -c "cd ./release && ./install-service.sh"  | Out-Null
  Start-Sleep -Seconds 0.25

  docker exec -it $runContainer /usr/bin/bash -c "dos2unix /usr/sbin/ps-tms/**/*.sh && dos2unix /usr/sbin/ps-tms/*.sh" | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Deleting start from pstms user ..."
  docker exec -it $runContainer /usr/bin/bash -c "sed -i 's/sudo -u pstms //' /usr/sbin/ps-tms/front-end-server/start_servers.sh" | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Done ✅ -> Use start script for launch ps-tms"
}

function Run {
  $status = (docker inspect pstms-runner | ConvertFrom-Json).State.Status

  if ($status -ne "running") {
    Write-Host "[INFO] Running $runContainer container ..."
    docker container start $runContainer
  }

  Write-Host "[INFO] Start pstms ..."
  docker exec -it $runContainer /usr/bin/bash -c "cd ./release && /usr/sbin/ps-tms/front-end-server/start_servers.sh"
}

function Delete {
  docker container rm -f $runContainer
  docker container rm -f $buildContainer
}

try {
  switch ($selectedMenu) {
    "1" {
      Build
      Prepare
    }
    "2" {
      Delete
    }
    "3" {
      Write-Host "[🚫] Not implemented"
    }
    "4" {
      Run
    }
    "5" {
      Prepare
    }
    Default {
      Write-Host "[🚫] Selected wrong menu"
    }
  }
}
catch {
  Write-Host "[🚫] Some error ..."
}