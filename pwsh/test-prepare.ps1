$config = Get-Content -Raw config.json | ConvertFrom-Json

$pstmsTestDir = $config.pstmsTestDir
$testContainer = $config.testContainer
$network = $config.network

try {
  Write-Host "[ℹ️] Deleting (if) existing container"
  docker container rm -f $testContainer | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Pulling ubuntu ..."
  docker pull ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Runing $testContainer ..."
  docker run -itd --network=$network --name $testContainer ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Setting timezone -> "
  docker exec -it $testContainer /usr/bin/bash -c "echo UTC > /etc/timezone"
  docker exec -it $testContainer /usr/bin/bash -c "cat /etc/timezone"
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Updating ubuntu ..."
  docker exec -it $testContainer apt update | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Install dependences (java 11, maven) ..."
  docker exec -it $testContainer apt install -y openjdk-11-jre vim dos2unix maven | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Copying ps-tms-selenium-tests ..."
  docker cp $pstmsTestDir ${testContainer}:/ps-tms-selenium-tests
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Install maven localy dependency ..."
  docker exec -it $testContainer /usr/bin/bash -c "mvn install:install-file -Dfile=/ps-tms-selenium-tests/ps-tms-pos-emulator-0.0.1-SNAPSHOT.jar -DgroupId=com.sonoma.pstms -DartifactId=ps-tms-pos-emulator -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar"
  docker exec -it $testContainer /usr/bin/bash -c "mvn install:install-file -Dfile=/ps-tms-selenium-tests/rest-client-0.0.1-SNAPSHOT.jar -DgroupId=com.sonoma.pstms -DartifactId=rest-client -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar"
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Compile project ..."
  docker exec -it $testContainer /usr/bin/bash -c "cd /ps-tms-selenium-tests && mvn install clean -T 16 -DskipTests"
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Done ✅ -> use './docker/test.ps1'"
} catch { 
  Write-Host "[🚫] Some error ..."
}
