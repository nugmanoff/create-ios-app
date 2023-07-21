# Инфраструктура

В проекте используется несколько инфраструктурных инструментов. Ниже краткое описание использования каждого из них и ответ на вопрос “Зачем?”

## Tuist

Tuist фактически является Infrastructure-as-a-Code инструментом для iOS проектов:

- Позволяет описывать конфигурацию проекта (build settings, project/target settings, schemes, build configs) в виде type-safe манифест файлов, которые валидируются посредством компиляции, тем самым не позволяя создавать не-валидные конфигурации.
- Позволяет работать с Xcode проектами на уровне файлов и конфигов, не заморачиваясь хрупкими, специфичными XML файлами по типу `.pbxproj` или `.xcodeproj`. Тем самым решая ряд проблем вроде неконтролируемых PBX merge конфликтов.
- Упрощает процесс модуляризации и масштабирования ваших проектов путём предоставления всех нужных абстракций для создания воспроизводимого способа создавать новые модули, таргеты по уже готовым шаблонам.
- Можно переиспользовать свои наработки по работе с Xcode проектами абстрагируя их в Tuist плагины.
- Можно описывать различные задачи по автоматизации вашего проекта с помощью вложенных Tuist CLI команд.
- Благодаря интеграции с SwiftGen из под коробки, есть первоклассная поддержка кодогенерации аксессоров для ресурсов, скаффолдинга новых модулей и т.п.

Вкратце о том, из каких частей состоит Tuist конфигурация в проекте:

`**Dependencies.swift**`

- Описывает все сторонние зависимости. Прямая поддержка SPM и Carthage. Для работы с CocoaPods необходимо иметь свой сторонний Podfile, который будет запускаться после генерации Tuist проекта. Подробнее [здесь](https://docs.tuist.io/1/guides/dependencies/).
- В `baseSettings` проставляются конфигурации для всех таргетов зависимостей, чтобы совпадать с основным приложением (`production`, `staging`) и не кидать лишних ворнингов.

```swift
import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            .remote(url: "https://github.com/krzysztofzablocki/Inject.git", requirement: .upToNextMajor(from: "1.0.5")),
            .remote(url: "https://github.com/hhru/Nivelir.git", requirement: .upToNextMajor(from: "1.6.3")),
            .remote(url: "https://github.com/kean/Pulse.git", requirement: .upToNextMajor(from: "2.1.3")),
            .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.6.4")),
            .remote(url: "https://github.com/jonkykong/SideMenu.git", requirement: .upToNextMajor(from: "6.0.0")),
            .remote(url: "https://github.com/hmlongco/Factory.git", requirement: .upToNextMajor(from: "2.2.0")),
        ],
        baseSettings: Settings.settings(
            configurations: TargetConfiguration.allCases.map { $0.dependencyConfiguration() }
        )
    ),
    platforms: [.iOS]
)
```

`**Target.swift**`

- Основной файл где мы описываем таргеты и их зависимости и связываем всё вмсте
- Задаём все основные настройки (bundleId, название приложения, организации)
- Задаём `Info.plist` значения для приложения

```swift

enum App {
    static let bundleId = "com.nugmanoff.cia"
    static let displayName = "Create iOS App"
    static let organizationName = "nugmanoff"
    static let deploymentTarget = "13.0"
    
    static let developmentTeamId = "8526SDA4V4"
    static let targetName = "App"
}

extension Project {
    // С текущим сетапом 1 проект - N таргетов
    // мы создаём один проект и проставляем ему все нужные таргеты (апп, модули)
    // Можно поменять на 1 проект - 1 таргет, но тогда нужно будет использовать Workspace.swift
    public static func main() -> Project {
        Project(
            name: App.targetName,
            organizationName: App.organizationName,
            settings: Settings.settings(configurations: TargetConfiguration.allCases.map { $0.configuration() },
                                        defaultSettings: .recommended(excluding: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS"])),
            targets: [
                app(name: App.targetName, dependencies: [
                    // Внутренние зависимости от других, модулей указываем
                    // через .target
                    .target(name: "UI"),
                    .target(name: "Infra"),
                    .target(name: "Resources"),
                    .target(name: "Convenience"),
                    // Когда вы добавляете внешнюю зависимость, 
                    // нужно написать название этой зависимости, так как она объявлена
                    // в её Package.swift манифесте
                    .external(name: "Inject"),
                    .external(name: "Nivelir"),
                    .external(name: "SideMenu"),
                    .external(name: "Factory"),
                    .external(name: "Pulse"),
                    .external(name: "PulseUI")
                ]),
                module(name: "UI", dependencies: [
                    .target(name: "Resources"),
                    .target(name: "Convenience")
                ]),
                // Указываем флаг `noResources` для тех зависимостей
                // где нет никаких ресурсов, чтобы избежать ворнингов 
                // о пустой папке с ресурсами
                module(name: "Infra", noResources: false, dependencies: [
                    .external(name: "Alamofire"),
                    .external(name: "Pulse")
                ]),
                module(name: "Resources", noResources: false),
                module(name: "Convenience")
            ],
            schemes: TargetScheme.allCases.map { $0.getScheme(for: App.targetName) },
            // Чтобы не генерировать ненужный header вверху каждого нового файла
            fileHeaderTemplate: .string("")
        )
    }
    
    // Это функция которая описывает основной таргет приложения
    private static func app(name: String, dependencies: [TargetDependency] = []) -> Target {
        // Описание Info.plist значений приложения
        let infoPlist: [String: InfoPlist.Value] = [
						// Переменные $APP_DISPLAY_NAME, $APP_BUNDLE_IDENTIFIER, $APP_BUNDLE_NAME
		        // Создаются в TargetConfiguration
            "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
            "CFBundleIdentifier": "$(APP_BUNDLE_IDENTIFIER)",
            "CFBundleName": "$(APP_BUNDLE_NAME)",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen",
            "NSBonjourServices": ["_pulse._tcp"]
        ]
        
        return Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: "$(APP_BUNDLE_IDENTIFIER)",
            deploymentTarget: .iOS(targetVersion: App.deploymentTarget, devices: .iphone),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/App/Sources/**"],
            resources: ["Targets/App/Resources/**"],
            dependencies: dependencies
        )
    }

    // Это функция которая описывает доп. модули
    public static func module(name: String, noResources: Bool = true, dependencies: [TargetDependency] = []) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "com.\(name).module",
            deploymentTarget: .iOS(targetVersion: App.deploymentTarget, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: noResources ? [] : ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )
    }
}
```

`**TargetScheme.swift**`

- Корневой сущностью является enum, где каждый кейс это схема основного приложения.
- По дефолту есть две схемы: `staging` и `production`, для добавления еще одной нужно просто добавить кейс в enum и добавить хэндлинг во все switch стейтменты.

```swift
public enum TargetScheme: CaseIterable {
    case staging
    case production
    
    public func getScheme(for target: String) -> Scheme {
        Scheme(
            name: schemeName(for: target),
            shared: true,
            buildAction: .init(targets: ["\(target)"]),
            runAction: .runAction(configuration: configurations.debug.name),
            archiveAction: .archiveAction(configuration: configurations.release.name),
            profileAction: .profileAction(configuration: configurations.release.name),
            analyzeAction: .analyzeAction(configuration: configurations.debug.name)
        )
    }
    
    private func schemeName(for target: String) -> String {
        switch self {
        case .staging:
            return "\(target)(Staging)"
        case .production:
            return "\(target)"
        }
    }

    private var configurations: (debug: TargetConfiguration, release: TargetConfiguration) {
        switch self {
        case .staging:
            return (.debugStaging, .releaseStaging)
        case .production:
            return (.debugProduction, .releaseProduction)
        }
    }
}
```

`**TargetConfiguration.swift`** 

- Конфигурация это конкретный набор **настроек**, который принимается к **таргету** при выборе определенной **схемы**.
- Есть два возможных типа конфигурации: `debug` и `release`:
    - `debug` конфигурации применяется при сборке на симулятор или на устройство через Xcode.
    - `release` конфигурации применяется во всех остальных случаях (архивирование, отправка в AppStore и т.д.)
- Получается для каждой схемы (`release` , `staging`) мы создаём по две конфигурации (`debug`, `release`) итого у нас получается 4 конфигурации: `releaseProduction`, `releaseStaging`, `debugProduction`, `debugStaging`.
- Для того, чтобы добавить новый build setting для определенной схемы, нужно добавить необходимое поле в результат вызова функции `settings` и по аналогичной схемы создать функцию, которая будет возвращать значение, в зависимости от текущей конфигурации посредством `switch` стейтмента.

```swift
public enum TargetConfiguration: CaseIterable {
    case debugStaging
    case debugProduction
    case releaseStaging
    case releaseProduction
}

extension TargetConfiguration {
    func configuration() -> Configuration {
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name, settings: settings())
        case .releaseStaging, .releaseProduction:
            return .release(name: name, settings: settings())
        }
    }
    
    public func dependencyConfiguration() -> Configuration {
        switch self {
        case .debugStaging, .debugProduction:
            return .debug(name: name)
        case .releaseStaging, .releaseProduction:
            return .release(name: name)
        }
    }

    var name: ConfigurationName {
        switch self {
        case .debugStaging:
            return .configuration("Debug(Staging)")
        case .debugProduction:
            return .configuration("Debug(Production)")
        case .releaseStaging:
            return .configuration("Release(Staging)")
        case .releaseProduction:
            return .configuration("Release(Production)")
        }
    }

    private func settings() -> [String: SettingValue] {
        [
            "APP_BUNDLE_NAME": "\(App.targetName)",
            "APP_DISPLAY_NAME": displayName(),
            "APP_BUNDLE_IDENTIFIER": "\(bundleIdentifier())",
            "PRODUCT_BUNDLE_IDENTIFIER": "\(bundleIdentifier())",
            "DEVELOPMENT_TEAM": "\(App.developmentTeamId)",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": provisioningProfile(),
            "CODE_SIGN_IDENTITY": codeSignIdentity(),

        ]
    }

    private func displayName() -> SettingValue {
        switch self {
        case .debugStaging, .releaseStaging:
            return "\(App.displayName) Staging"
        case .debugProduction, .releaseProduction:
            return "\(App.displayName)"
        }
    }
    
    private func provisioningProfile() -> SettingValue {
        switch self {
        case .debugStaging, .debugProduction:
            return "match Development \(bundleIdentifier())"
        case .releaseStaging:
            return "match AdHoc \(bundleIdentifier())"
        case .releaseProduction:
            return "match AppStore \(bundleIdentifier())"
        }
    }

    private func codeSignIdentity() -> SettingValue {
        switch self {
        case .debugStaging, .debugProduction:
            return "iPhone Developer"
        case .releaseStaging, .releaseProduction:
            return "iPhone Distribution"
        }
    }

    private func bundleIdentifier() -> String {
        switch self {
        case .debugStaging, .releaseStaging:
            return "\(App.bundleId).staging"
        case .debugProduction, .releaseProduction:
            return "\(App.bundleId)"
        }
    }
}
```

## Inject

Это инструмент, который позволяет HotReload-ить (обновлять приложения на симуляторе без рекомпиляции) iOS приложения. Требует 3-х минутной разовой интеграции на компьютере разработчика и вследствии сэкономить часы времени в неделю. 

Этот инструмент уже подключить в проект как зависимость, нужно только произвести настройки на компьютерах разработчиков. 

[github.com/krzysztofzablocki/inject](http://github.com/krzysztofzablocki/inject) 

## Pulse

Полноценный Network (и не только) logger для iOS приложений. В разы лучше встроенного в macOS [Console.app](http://Console.app) или Xcode-овской консоли. Так же позволяет смотреть логи напрямую с устройства, тем самым выполняя роль логгера, просмотров логов для разработчиков и просмотров логов для QA. 

https://github.com/kean/Pulse
