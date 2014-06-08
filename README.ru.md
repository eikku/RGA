# RGA

Данный пакет предназначен для работы с API **Google Analytics** в **R**.

Основные возможности:

* Поддержка OAuth 2.0 аутентификации;
* Доступ к API конфигурации (информация об аккаунтах, профилях, целях, сегментах);
* Доступ к API базовых отчётов и отчётов многоканальных последовательностей;
* Поддержка пакетной обработки запросов (позволяет преодолеть ограничение на количество возвращаемых строк на один запрос).
* Доступ к метаданным API отчётов.

## Установка

**Внимание:** Пакет **RGA** находится в разработке и не доступен через сеть **CRAN**.

### Предварительные требования

* **R** версии не ниже **2.15.0**;
* Пакеты `RCurl`, `httr` и `jsonlite`;
* Пакет `devtools`.

### Установка пакет `devtools`

Установить актуальную версию пакета `devtools` можно с помощью команды:

```R
install.packages("devtools", dependencies = TRUE)
```

### Установка пакета `RGA`

Установить пакет `RGA` можно из гит-репозитория:

```R
library(devtools)
install_bitbucket(repo = "rga", username = "unikum")
```

## Подготовка

### Получение ключей для доступа к API Google Analytics

Прежде ем приступить к работе с пакетов `RGA`, необходимо создать новое приложение в [Google Developers Console](https://console.developers.google.com) и получить **Client ID** (идентификатор клиента) и **Client secret** (секретный ключ клиента) для доступа API Google Analytics.

Пошаговая инструкция приведена ниже.

1. Создание нового проекта:
    * Открыть страницу https://console.developers.google.com/project;
    * В левой верхней части страницы нажать на красную кнопку с надписью **Create Project**;
    * Во всплывающем окне в поле **PROJECT NAME** ввести название проекта;
    * Подтвердить создание проекта, нажав на кнопку **Create**.
1. Активация доступа к API Google Analytics:
    * Выбрать проект в списке проектов на странице https://console.developers.google.com/project;
    * На боковой панели слева выбрать пункт **APIs & auth**;
    * на вкладке **APIs** активировать **Analytics API**, нажав на кнопку с надписью `OFF`.
1. Создание нового приложения:
    * В боковой панели слева выбрать пункт **APIs & auth**, подпункт **Credentials**;
    * В левой части страницы нажать на кнопку с надписью **Create new Client ID**;
    * Во всплывающем окне необходимо выбрать пункт **Installed application** в списке **APPLICATION TYPE** и пункт **Other** в списке **INSTALLED APPLICATION TYPE**.
    * Подтвердить создание приложения, нажав на кнопку с надписью **Create Client ID**.
1. Получение Client ID (идентификатора клиента) и Client secret (секретного ключа клиента):
    * В боковой панели слева выбрать пункт **APIs & auth**, подпункт **Credentials**;
    * В таблице с названием **Client ID for native application** скопировать значения полей **Client ID** и **Client secret**.

### Установка переменных окружения (не обязательно)

Пакет `RGA` может импортировать значения **Client ID** и **Client secret** из [переменных среды](http://ru.wikipedia.org/wiki/Переменная_среды). Пакет `RGA` извлекает информацию из следующих переменных среды: `RGA_CONSUMER_ID` и `RGA_CONSUMER_SECRET`.

Установка переменных сред отличается для разных операционных систем, поэтому пользователю необходимо обратиться к соответствующим справочным материалам. Также существуют способы установки переменных сред при запуске R-сессий с помощью файлов `.Renviron’ в рабочей или домашней директории пользователя. Содержимое файла может выглядеть примерно так:

```txt
RGA_CONSUMER_ID="My_Client_ID"
RGA_CONSUMER_SECRET="My_Client_secret"
```

Переменные среды можно также установить непосредственно из R-сессии с помощью функции `Sys.setenv`. Например:

```R
Sys.setenv(RGA_CONSUMER_ID = "My_Client_ID", RGA_CONSUMER_SECRET = "My_Client_secret")
```

Эту строку можно также добавить в в файл `.Rprofile` в текущей или домашней директории пользователя, чтобы данные переменные автоматически устанавливались при запуске R-сессии.

## Работа с пакетом

### Получение токена доступа

Перед осуществление любых запросов к API, необходимо пройти авторизацию и получить токен доступа. Осуществить это можно с помощью следующей команды:

```R
token <- get_token(client.id = "My_Client_ID", client.secret = "My_Client_secret")
```

Отметим, что если были заданны переменные среды `RGA_CONSUMER_ID` и `RGA_CONSUMER_SECRET`, то указанием аргументов `client.id` и `client.secret` при вызове функции `get_token` не требуется.

После выполнения команды будет открыт браузер по умолчанию. Необходимо авторизоваться под своей **учётной записью Google** и подтвердить разршение на доступ к данным Google Analytics (доступ предоставляется **только для чтения** данных).

Если использовались аргументы по умолчанию и не изменялся параметр `httr_oauth_cache`, то после успешной авторизации в рабочй директории будет создан файл `.httr-oauth` с данными для доступа к Google API, который будет использоваться между сессиями. С помощью аргумента `cache` можно также отменить создание файла (значение `FALSE`) или задать альтернативный путь к файлу хранения (для этого необходимо явно указать путь и имя файла).

Полученная переменная `token` будет использоваться во всех запросах к API Google Analytics.

### Получние доступа к API конфигурации

Для доступа к API конфигурации Google Analytics предусмотрены следующие функции:

* `get_accounts` - получение списка аккаунтов в, к которым пользователь имеет доступ;
* `get_webproperties` - получение списка ресурсов (Web Properties), к которым пользователь имеет доступ;
* `get_profiles` - получение списка ресурсов (Web Properties) и представлений (Views, Profiles) сайтов, к которым пользователь имеет доступ;
* `get_goals` - получение списка целей, к которым пользователь имеет доступ;
* `get_segments` - получение списка сегментов, к которым пользователь имеет доступ.

Для функций `get_webproperties`, `get_profiles` и `get_goals` можно указать дополнительные опции: для какой аккаунта, ресурса или представление получить информацию (см. страницы помощи к соответствующим функциям). Пример использования функции приведён ниже:

```R
get_profiles(token = token)
```

### Получние доступа к метаданным API отчётов

Для получения списка всех показателей (metrics) и измерений (dimensions) пакет `RGA` предоставляет функцию `get_metadata`.

```R
ga_meta <- get_metadata()
```

Переменная `ga_meta` имеет класс `data.frame` и содержит следюущие столбцы:

* ids - кодовое название параметра (показателя или измерения) (используется для запросов);
* type - тип параметра: показатель (METRIC) или измерение (DIMENSION);
* dataType - тип данных: STRING, INTEGER, PERCENT, TIME, CURRENCY, FLOAT;
* group - группа параметров (например, User, Session, Traffic Sources);
* status - статус: актуальный (PUBLIC) или устаревший (DEPRECATED);
* uiName - имя параметра (не используется для запросов);
* description - описание параметра.
* allowedInSegments - может ли параметр использоваться в сегментах;
* replacedBy - название заменяющего параметра, если параметр объявлен устаревшим;
* calculation - формула расчёта значения параметра, если параметр вычисляется на основе данных других параметр;
* minTemplateIndex - если параметр сдержик числовой индекс, минимальный индекс для параметра;
* maxTemplateIndex - если параметр сдержик числовой индекс, максимальный индекс для параметра;
* premiumMinTemplateIndex - если параметр сдержик числовой индекс, минимальный индекс для параметра;
* premiumMaxTemplateIndex - если параметр сдержик числовой индекс, максимальный индекс для параметра;

Несколько примеров использования метаданных Google Analytics API.

Список всех устаревших и заменяющих их параметров:

```R
subset(ga_meta, status == "DEPRECATED", c(ids, replacedBy))
```

Список всех параметров из определённой группы:

```R
subset(ga_meta, group == "Traffic Sources", c(ids, type))
```

### Получение доступа к API отчётов

Доступ к API очтётов может быть получен двумя способами.

## Ссылки

* [Google Developers Console](https://console.developers.google.com/project);
* [Management API Reference](https://developers.google.com/analytics/devguides/config/mgmt/v3/mgmtReference/)
* [Core Reporting API Reference Guide](https://developers.google.com/analytics/devguides/reporting/core/v3/reference)
* [Multi-Channel Funnels Reporting API Reference Guide](https://developers.google.com/analytics/devguides/reporting/mcf/v3/reference)
* [Metadata API Reference](https://developers.google.com/analytics/devguides/reporting/metadata/v3/reference/)
* [Configuration and Reporting API Limits and Quotas](https://developers.google.com/analytics/devguides/reporting/metadata/v3/limits-quotas)