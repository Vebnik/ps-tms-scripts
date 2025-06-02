param($isCopy)

if ($isCopy) {
  Write-Host "[ℹ️] Copying from docker..."
  docker cp ps-tms-ubuntu:/sbin/ps-tms/PS-TMS-work/importer-service/db/poslogs.mv.db  ./poslogs.mv.db
} else {
  Write-Host "[ℹ️] Copying to docker..."

  docker exec -it ps-tms-ubuntu /usr/bin/bash -c "rm /sbin/ps-tms/PS-TMS-work/importer-service/db/poslogs.mv.db"
  Start-Sleep -Seconds 0.25

  docker cp ./poslogs.mv.db  ps-tms-ubuntu:/sbin/ps-tms/PS-TMS-work/importer-service/db/poslogs.mv.db
  Start-Sleep -Seconds 0.25
}