# How to use this terrible scripts

## Windows - docker

### Prepare

1. Update powershell to 7.5.0
2. Install docker desktop

### Launch ps-tms
1. Make config file `config.json`

2. Run `.\pwsh\run.ps1
```text
Эта команда содержит меню для интерактивного взаимодействия
```

### Launch ps-tms-test
```
Выполнить предыдущие шаги или начать со второго, чтобы установить чистую ps-tms
```
1. Run `.\docker\selenium.ps1`
```
Эта команда запустит selenium-grid в контейнере
```

2. Замена IP адресов в `Defaults.java` (src/main/java/com/sonoma/pstms/selenium/util/Defaults.java)
```java
package com.sonoma.pstms.selenium.util;

public class Defaults {

    private Defaults() {
        throw new IllegalStateException("Utility class");
    }

    public static final String DEFAULT_IP = "172.17.0.1"; // docker host ip
    public static final String DEFAULT_CHROMIUM_IP = "172.17.0.1"; // docker host ip
    public static final String DEFAULT_DB_IP = "172.17.0.1"; // docker host ip
    public static final int DEFAULT_UI_PORT = 443; // port ui tms https
    public static final int DEFAULT_PROTO_PORT = 8000;
    public static final int DEFAULT_PROTO_SSL_PORT = 9000;
    public static final String DEFAULT_DB_TYPE = System.getProperty("dbType") == null ? "h2" : System.getProperty("dbType");
    public static final String ADMIN_PASSWORD = "super_puper_secret_password";
}
```

3. Добавление зависимостей в `pom.xml`
```xml
<dependencies>
  <dependency>
    <groupId>org.apache.httpcomponents</groupId>
    <artifactId>httpclient</artifactId>
    <version>4.5.2</version>
  </dependency>
...
```

4. Добавление конфигурации UTF-8 при сборке в `pom.xml`
```xml
<properties>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
```

5. Run `.\docker\test-prepare.ps1
```
Эта команда запустит контейнер и подготовит окружение для запуска тестов
```

6. Run `.\docker\test.ps1`
```
Эта команда запустит основные тесты
```