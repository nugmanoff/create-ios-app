# create-ios-app

Шаблон для создания iOS проектов. 

## Начало работы

1. Установить tuist
```
curl -Ls https://install.tuist.io | bash
```

2. Открываем настройки проекта
```
tuist edit
```

3. Открываем `Target.swift` и в структуре `App` меняем все нужные настройки
```
enum App {
    static let bundleId = "com.nugmanoff.cia"
    static let displayName = "Create iOS App"
    static let organizationName = "nugmanoff"
    static let deploymentTarget = "13.0"
    static let developmentTeamId = "8526SDA4V4"
    static let targetName = "App"
}
```

4. Генерируем проект, устанавливаем зависимости и открываем его
```
tuist fetch && tuist generate 
```

Для удобства можно создать alias-ы:
```
alias tg="tuist fetch && tuist generate"
alias te="tuist edit"
```

## Документация

К этому шаблону прилагается документация, которая состоит из:
- [Краш-курс по мобильной архитектуре](Docs/crash-course.md)
- [Описание архитектуры проекта](Docs/architecture.md)
- [Описание файловой структуры проекта](Docs/file-structure.md)
- [Описание инфраструктуры проекта](Docs/infrastructure.md)

## Дополнительно

### Установка инфраструктурных зависимостей

Для эффективной работы необходимо установить [Inject](https://github.com/krzysztofzablocki/Inject) (хотрелоуд проектов) и [Pulse](https://github.com/kean/Pulse) (логгер и приложение для просмотра логов).

### Как добавлять стороннюю зависимость

1. Выполняем команду `tuist edit`
2. Открываем `Dependencies.swift`
3. Добавляем строчку с зависимостью
4. Добавляем название зависимости в нужный таргет в файле `Target.swift`. Название можно посмотреть в `Package.swift` файле в репозитории зависимости. Пример с [Alamofire](https://github.com/Alamofire/Alamofire/blob/master/Package.swift#L33) (то, что написано в `library(name:` и есть название модуля)

### Как добавить новый модуль

1. Создаём папку в директории `Targets` с названием модуля и вложенной папкой `Sources`
2. Выполняем команду `tuist edit`
3. Открываем `Target.swift`
4. В функции `main` в массив под аргументом `targets` добавляем нашу новую зависимость. Имя которой мы передаём в функцию `module` должено совпадать с названием папки.
5. Генерируем проект заново – `tuist generate` и видим наш новый модуль.
