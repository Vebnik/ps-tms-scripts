# How to use this terrible scripts

## Windows - docker

### Prepare

1. Update powershell to 7.5.0
2. Install docker desktop

### Launch ps-tms
1. Run `.\docker\build.ps1 "path\to\pstms\root\folder"`
```text
Эта команда сбилдит ps-tms из исходников в контейнере и скопирует ps-tms-packer-SNAPSHOT-bin.tar в текущую директорию выполения скрипта.
```

2. Run `.\docker\prepare.ps1 "absolute\path\to\ps-tms-packer-SNAPSHOT-bin.tar.gz"`
```text
Эта команда распакует и установит сервисы ps-tms в контейнере
```

3. Run `.\docker\start.ps1"`
```text
Эта команда запустит ps-tms в интерактивном режиме (стоп через ctrl + c)
```

### Launch ps-tms-test
```
Выполнить предыдущие шаги или начать со второго, чтобы установить чистую ps-tms
```
1. Run `.\docker\selenium.ps1`
```
Эта команда запустит selenium-grid в контейнере
```

2. Run `.\docker\test.ps1 "path\to\ps-tms-selenium-tests\root\folder"`
```
Эта команда запустит контейнер и подготовит окружение для запуска тестов
```

3. Run `docker exec -it ps-tms-test bash`
```
Подключаемся к контейнеру с тестами в интерактивном режиме.
  1. mvn clean install -Dtest=com.sonoma.pstms.selenium.LoginTest - первичные тесты для создания тестовых пользователей
  2. Обновляем лицензию (узнать где-нибудь в чате)
  3. mvn clean install - Запуск основных тестов
```