param($psTmsDir)
$currentDir=Get-Location
$targetContainer = "ps-tms-ubuntu-builder"

function GetContainer {
  try {
    $container = docker inspect $targetContainer | ConvertFrom-Json

    if (!$container) {
      return $false
    }

    Write-Host "[ℹ️] Finded container: " $container.Id

    return $true
  } catch {
    return $false
  }
}

function CheckExistNetwork {
  try {
    $network = docker network inspect pstms | ConvertFrom-Json

    if (!$network) {
      docker network create pstms

      $network = docker network inspect pstms | ConvertFrom-Json
      Write-Host "[ℹ️] Created network: " $network.Id

      return
    }

    Write-Host "[ℹ️] Finded network: " $network.Id
    return
  } catch {
    Write-Host "[🚫] Some error ..."
  }
}


if (!$psTmsDir) {
  Write-Host "[ERROR] Not found psTmsDir first arg"
}

$ifExist = GetContainer
CheckExistNetwork

if (!$ifExist) {
  Write-Host -NoNewline "[ℹ️] Creating logs directory ... "
  if (Test-Path logs) {
    Write-Host "Directory exists"
  } else {
    mkdir logs
    Write-Host "Directory created"
  }
  Start-Sleep -Seconds 0.25

  # pulling ubuntu
  Write-Host "[ℹ️] Pulling ubuntu ..."
  docker pull ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  # run docker as bg tasks
  Write-Host "[ℹ️] Runing ps-tms-ubuntu-builder ..."
  docker run -itd --name ps-tms-ubuntu-builder ubuntu
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Setting timezone -> "
  docker exec -it ps-tms-test /usr/bin/bash -c "echo UTC > /etc/timezone"
  docker exec -it ps-tms-test /usr/bin/bash -c "cat /etc/timezone"
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Update apt ..."
  docker exec -it ps-tms-ubuntu-builder apt update
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Install java 21 ..."
  docker exec -it ps-tms-ubuntu-builder apt install -y openjdk-21-jre vim dos2unix
  Start-Sleep -Seconds 0.25
} else {
  Write-Host -NoNewline "[ℹ️] Runing exist ps-tms-ubuntu-builder ..."
  docker start ps-tms-ubuntu-builder
  Start-Sleep -Seconds 0.25  

  Write-Host "[ℹ️] Deleting exist ps-tms ..."
  docker exec -it ps-tms-ubuntu-builder /usr/bin/bash -c "rm -r /pstms"
  Start-Sleep -Seconds 0.25  
}

try { 
  Write-Host -NoNewline "[ℹ️] Copying ps-tms ..."
  docker cp $psTmsDir ps-tms-ubuntu-builder:/
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Execution dos2unix ..."
  docker exec -it ps-tms-ubuntu-builder /usr/bin/bash -c "cd /pstms && dos2unix ./mvn/bin/* && dos2unix ./mvn/bin/* && dos2unix ./**/*/*.sh &&  dos2unix ./*.sh" | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Building ps-tms ..."
  docker exec -it ps-tms-ubuntu-builder /usr/bin/bash -c "cd /pstms && ./build.sh" | Out-File -FilePath ./logs/build-logs.log
  Start-Sleep -Seconds 0.25

  # run copy and extract ps-tms
  Write-Host -NoNewline "[ℹ️] Copying ps-tms-packer ..."
  docker cp ps-tms-ubuntu-builder:/pstms/ps-tms-packer/target/ps-tms-packer-SNAPSHOT-bin.tar.gz $currentDir/ps-tms-packer-SNAPSHOT-bin.tar.gz
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Done ✅ -> use prepare script for install ps-tms"
} catch { 
  Write-Host "[🚫] Some error ..."
}