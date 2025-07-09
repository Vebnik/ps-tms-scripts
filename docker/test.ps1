
param($psTmsTest)

try {
  Write-Host "[ℹ️] Deleting (if) existing container"
  docker container rm -f ps-tms-test | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Pulling ubuntu ..."
  docker pull ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Runing ps-tms-test ..."
  docker run --network=pstms -itd --name ps-tms-test ubuntu | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Setting timezone -> "
  docker exec -it ps-tms-test /usr/bin/bash -c "echo UTC > /etc/timezone"
  docker exec -it ps-tms-test /usr/bin/bash -c "cat /etc/timezone"
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Updating ubuntu ..."
  docker exec -it ps-tms-test apt update | Out-Null
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Install jdk 11 ..."
  docker exec -it ps-tms-test apt install -y openjdk-21-jre vim dos2unix maven
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Copying ps-tms-selenium-tests ..."
  docker cp $psTmsTest ps-tms-test:/ps-tms-selenium-tests
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Install maven localy dependency ..."
  docker exec -it ps-tms-test /usr/bin/bash -c "mvn install:install-file -Dfile=/ps-tms-selenium-tests/ps-tms-pos-emulator-0.0.1-SNAPSHOT.jar -DgroupId=com.sonoma.pstms -DartifactId=ps-tms-pos-emulator -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar"
  docker exec -it ps-tms-test /usr/bin/bash -c "mvn install:install-file -Dfile=/ps-tms-selenium-tests/rest-client-0.0.1-SNAPSHOT.jar -DgroupId=com.sonoma.pstms -DartifactId=rest-client -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar"
  Start-Sleep -Seconds 0.25

  Write-Host -NoNewline "[ℹ️] Compile project ..."
  docker exec -it ps-tms-test /usr/bin/bash -c "cd /ps-tms-selenium-tests && mvn install clean -T 16 -DskipTests"
  Start-Sleep -Seconds 0.25

  Write-Host "[ℹ️] Done ✅ -> use 'mvn install -Dtest=com.sonoma.pstms.selenium.LoginTest'"
} catch { 
  Write-Host "[🚫] Some error ..."
}

# mvn clean install -Dtest=com.sonoma.pstms.selenium.LoginTest test
# mvn clean install -T 16 -DnodeIp=host.docker.internal -Dtest=com.sonoma.pstms.selenium.LoginTest test

# mvn install:install-file -Dfile=/ps-tms-selenium-tests/ps-tms-pos-emulator-0.0.1-SNAPSHOT.jar -DgroupId=com.sonoma.pstms -DartifactId=ps-tms-pos-emulator -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar
# mvn install:install-file -Dfile=/ps-tms-selenium-tests/rest-client-0.0.1-SNAPSHOT.jar -DgroupId=com.sonoma.pstms -DartifactId=rest-client -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar