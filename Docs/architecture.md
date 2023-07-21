# Архитектура

# Введение

Теперь попробуем описать разумную архитектуру с учетом того, что мы поняли про архитектуры мобильных приложений, а так же с учетом реалий рынка, уровня разработчиков в Казахстане, и природы проектов.

Семейство UDF (Unidirectional Data Flow) архитектур хорошо подходит для мобильных приложений по своей природе сфокусированности на проектировании управления состоянием и потоков данных, что является, как мы поняли, первостепенным при разработке приложений. 

Но, к сожалению, UDF в “чистом виде” может нести добавленную сложность для понимания, ввиду своих корней из функционального программирования, алгебраичных типов данных, математики лямбда вычислений, теории категорий и так далее. 

Поэтому в этом вопросе очень важно **разумно** отнестись к построению архитектуры, а это значит где-то делать в “не чистом” виде, знать какие правила “можно нарушить” и так далее.

# Структура

Наша разумная архитектура затрагивает следующие части:

1. State Management
2. Presentation Layer
3. Application/Domain Layer
4. Navigation
5. DI

## State Management

В отличие от классического UDF (Immutable State, Reducer) наша реализация управления состояния является классическим двухсторонним биндингом (в стиле MVVM + RxSwift). 

Ключевой сущностью является объект `Store`, который служит обработчиком действий и источником обновлений. Каждый экран (`ViewController`) работает со своим `Store` посредством отправки действий (`Action`) в него и обработки событий (`Event`). 

В `ViewController` на стороне обработки событий, благодаря Combine и его first-class интеграции с SwiftUI мы бесплатно получаем реактивное применение обновлений экрана без лишнего бойлерплейт кода. 

```swift
import Combine

class Store<Event, Action> {
    private(set) var events = PassthroughSubject<Event, Never>()
    private(set) var actions = PassthroughSubject<Action, Never>()
    
    var bag = Set<AnyCancellable>()
    
    init() {
        setupActionHandlers()
    }
    
    func sendAction(_ action: Action) {
        actions.send(action)
    }
    
    func sendEvent(_ event: Event) {
        events.send(event)
    }
    
    func setupActionHandlers() {
        actions.sink { [weak self] action in
            self?.handleAction(action)
        }.store(in: &bag)
    }
    
    func handleAction(_ action: Action) {
        
    }
}
```

Для примера вот так выглядит Store

`EditProfileStore.swift` 

```swift
enum EditProfileEvent {
    case isLoading(Bool)
    case isSaveButtonEnabled(Bool)
    case showSuccess
}

enum EditProfileAction {
    case textDidChange(String)
    case saveButtonDidTap
}

final class EditProfileStore: Store<EditProfileEvent, EditProfileAction> {
    private var updateProfileNameUseCase = UpdateProfileNameUseCase()
    private var profileName = String()
    
    override func handleAction(_ action: EditProfileAction) {
        switch action {
        case .textDidChange(let text):
            profileName = text
            let isFieldTextValid = !text.isEmpty && text.count > 3
            sendEvent(.isSaveButtonEnabled(isFieldTextValid))
        case .saveButtonDidTap:
            Task {
                sendEvent(.isLoading(true))
                sendEvent(.isSaveButtonEnabled(false))
                await updateProfileNameUseCase.execute(profileName)
                sendEvent(.isLoading(false))
                sendEvent(.isSaveButtonEnabled(true))
                sendEvent(.showSuccess)
            }
        }
    }
}
```

И так выглядит ViewController, который на него подписан:

`EditProfileViewController.swift`

```swift
final class EditProfileViewController: UIViewController, UITextFieldDelegate {
    /* 
       - Тут настройка UI элементов и зависимостей. 
       - Так же Lifecycle методы.
    */
    
    private let store = EditProfileStore()
    
    private func configureObservers() {
        // Функция `bindStore` показана в следующем сниппете кода.
        bindStore(store) { [weak self] event in
            guard let self else { return }
            switch event {
            case .isLoading(let isLoading):
                buttonViewModel.isLoading = isLoading
            case .isSaveButtonEnabled(let isSaveButtonEnabled):
                buttonViewModel.isEnabled = isSaveButtonEnabled
            case .showSuccess:
                showSuccess()
            }
        }
        .store(in: &bag)
        
        textField
            .textPublisher
            .receiveOnMainQueue()
            .sink(receiveValue: { [weak self] text in
                self?.store.sendAction(.textDidChange(text))
            })
            .store(in: &bag)
    }
    
    private func onSaveDidTap() {
        store.sendAction(.saveButtonDidTap)
    }
    
    private func showSuccess() {
        let screen = EditProfileSuccessViewController()
        navigator.navigate(from: self) { route in
            route.stack.push(screen)
        }
    }
}
```

`bindStore` это простейшая функция которая слушает события из `Store` и выведена в удобный extension поверх `UIViewController`

```swift
extension UIViewController {
    func bindStore<Event, Action>(
         _ store: Store<Event, Action>,
         handler: @escaping (Event) -> Void) -> AnyCancellable {
			        store
			            .events
			            .receiveOnMainQueue()
			            .sink { event in
			                handler(event)
			            }
    }
}
```

**Что мы здесь нарушаем относительно традиционного UDF:**

- **Нет Immutable State.** У нас нету единой структуры где мы держим состояние конкретного экрана, мы просто обмениваемся обновлениями и каждый раз мутируем состояние, что может привести к несуществующим состояниям. Но понимания и эффективная работа с концептом Immutable State требует времени и определенной глубины команды разработки. Поэтому мы зажмуриваясь нарушаем это правило.
- **Нет Reducer.** В “правильном” UDF варианте Reducer это такая функция которая принимает на вход состояние (`State`) и действие (`Action`) и отдаёт как результат новое состояние (`State`). Но иногда определенное действие должно изменить что-то во внешнем мире (`Side Effect`), помимо нашего экрана/закрытой системы, и тогда открывается целый новый мир связанных проблем, на который мы тоже закрываем глаза в виду наших более реалистичных взглядов.

**Какие плюсы у наших нарушений:**

- **Простота понимания.** Так как это простой двухсторонний биндинг, его поймёт практически любой мобильный разработчик и ему будет довольно понятно как использовать такой код как “экземплярный”, т.е. как писать новый код смотря на него.
- **Достаточность.** Опять же, будучи реалистами, мы понимаем, что такая степень разделения ответственностей и управления состоянием *достаточна* для достижения желаемых результатов.
- **Низкий порог входа.** Для работы с этим кодом не нужно переучиваться и мыслить “чисто”, “функционально”, что повышает наши шансы на успех в виде более развязанных рук при найме разработчиков.

## Presentation Layer

Под презентационным слоем подразумевается а) то, что пользователь видит на экране б) то, с чем он взаимодействует в) то, что решает что ему отобразить на экране.

**State Management** так же принадлежит к этому слою, но в этой секции мы больше сфокусируемся на деталях реализации обновлений и показа.

Для презентационного слоя мы используем смесь UIKit и SwiftUI фреймворков. 
Есть несколько ключевых компонентов презентационного слоя:

- `ViewController` это ключевой компонент, который олицетворяет 1 экран. За исключением редких случаев работы с Container/Child контроллерами.
- `View` это либо UIKitовская `UIView` либо SwiftUIная `View`. В обоих случаях создаётся в виде computed `lazy var` переменной внутри контроллера и добавляется в рутовую вьюшку контроллера с помощью UIKit-овых констрейнтов.
    - SwiftUI вьюшки добавляются в UIKit иерархию посредством заворачивания в `UIHostingController`. Это происходит с помощью вспомогательных Bridging хэлперов. Это всё лежит в `Convenience` модуле в папке `Primitives/Bridge`
    - Поэтому при добавлении в иерархию контроллера, необходимо сначала добавить UIHostingController как childController, а потом использовать его рутовую вьюшку чтобы добавить его в иерархию.
- `ViewModel` это компонент связывающий вьюшки с состоянием и обработкой событий. В случае, когда вьюшки являются SwiftUI-ными вьюшками, `ViewModel` наследуется от `ObservableObject` тем самым открывая дорогу реактивным обновлениям и ререндерингу вьюшек в зависимости от изменения в состоянии. События из вьюшек (нажатие кнопок и другие пользовательские действия) обычно напрямую проксируются в `Store` через `ViewController`
    - `ViewModel` будучи `ObservableObject` создаётся и ссылка на него удерживается внутри `ViewController` -а для того, чтобы “не терять” состояние. Эту проблему c iOS 14.0 [решает](https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-stateobject-property-wrapper) `StateObject` чисто SwiftUI-ного подхода. Но мы его не используем, потому что у нас есть стабильный контроллер, который при ререндерах не теряется и может удерживать ссылку.

Так же при использовании гибридного UIKit + SwiftUI подхода необходимо соблюдать определенные правила:

- Вся навигация строится посредством UIKit абстракций: `UINavigationController`, `UITabBarController`, …
- Приоритизируем использование SwiftUI для всех “вьюшек” (маленьких, независимых частей интерфейса): кнопки, плашки, ячейки, …
- Приоритизируем использование UIKit для всех частей приложения, где предполагается нагрузка к производительности рендеринга и стабильности: большие списки, сложные списки, сложные взаимодействия со скроллом, …
- Комбинируем применение UIKit и SwiftUI для того, чтобы решать поставленную задачу лучшим возможным образом.
- Используем `ObservableObject` для реактивного обновления наших SwiftUI вьюшек после получения обновлений из `Store`. Вся эта “связка” происходит в `bindStore` методе в `ViewController`

Ниже рассмотрим пару кратких примеров кодов демонстрирующих некоторые из пунктов описанных выше. Примеры код и различных комбинаций использования SwiftUI и UIKit есть в шаблонном проекте в папке `Features/`. 

### SwiftUIная вьюшка в контроллере + создание ViewModel

```swift
final class QButtonViewModel: ObservableObject {
    var title: String
    @Published var isLoading: Bool
    @Published var isEnabled: Bool
    var onDidTap: Callback
}

final class AuthEnterPasswordViewController: UIViewController {
    private lazy var button = QButton(viewModel: buttonViewModel).bridge()
    
    private lazy var buttonViewModel = QButtonViewModel(
        title: "Login",
        isEnabled: true,
        onDidTap: onNextDidTap
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        /// так как результатом вызова функции bridge() является UIHostingController
        /// первым делом нужно добавить вьюшку как childController
        addChild(button)
        view.addSubview(button.view)
        child.didMove(toParent: self)

        /// либо использовать удобный extension метод
        add(button)
				
				/// важная деталь, что здесь констрейнты ставятся на `button.view`
        /// потому что button это UIHostingController
        button.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.view.heightAnchor.constraint(equalToConstant: 64),
            button.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            button.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            button.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
    }
}
```

### SwiftUIная вьюшка как ячейка + её использование в UITableView

```swift
typealias StocksListItemCell = BridgingRestrictedTableViewCell<StocksListItemView>

struct StocksListItemView: View {
    var stock: Stock
    
    var body: some View {
        HStack {
            Text(stock.symbol)
                .foregroundColor(.black)
            Spacer()
            Text(stock.value)
                .foregroundColor(.black.opacity(0.5))
        }
        .font(.subheadline)
        .padding()
    }
}

struct Stock {
    let symbol: String
    let value: String
}

final class StocksListViewModel {
    var stocks: [Stock] = [
        .init(symbol: "AAPL", value: "124.56$"),
        .init(symbol: "NFLX", value: "200.12$"),
        .init(symbol: "DISN", value: "72.11$"),
        .init(symbol: "GOOG", value: "56.84$"),
    ]
}

final class StocksListViewController: UIViewController {
    private lazy var tableView = UITableView()
    private lazy var viewModel = StocksListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
				tableView.apply {
            $0.dataSource = self
            $0.showsVerticalScrollIndicator = false
            $0.register(bridgingCellClass: StocksListItemCell.self)
        }
        view.addSubviewStickingToEdges(tableView)
    }
}

extension StocksListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stock = viewModel.stocks[indexPath.row]
        let cell: StocksListItemCell = tableView.dequeueReusableBridgingCell(for: indexPath)
        let view = StocksListItemView(stock: stock)
        cell.set(rootView: view, parentViewController: self)
        return cell
    }
}
```

### SwiftUIная вьюшка как рутовая вьюшка в контроллере

```swift
final class EditProfileSuccessViewController: UIViewController, Screen {
    private lazy var rootView: BridgedView = EditProfileSuccessView().bridge()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        /// это метод, который добавляет SwiftUIную вьюшку как childController
        /// и сразу задаёт ей констрейнты по размеру рутовой вьюшки и игнорирует
        /// SafeArea отступы
        addIgnoringSafeArea(rootView)
    }
}
```

## Application/Domain Layer

Как обсуждалось ранее, что в тонких клиентах бывает очень мало доменной логики, но иногда она бывает – и как лучше её проектировать и куда её ложить?

Зачастую то, что выдаётся за Domain Layer в приложениях чаще является Application Layer так как олицетворяет какие-то юзкейсы (т.е. пользовательские сценарии), который в свою очередь идут в домен и что-то делать (т.е. в случае тонкого клиента идут и делают запросы в сеть).

### UseCase

Удобной абстракцией на этом слое является сущность UseCase, которая под собой абстрагирует одно целевое, бизнес-действие, которое напрямую или косвенно может выполнять пользователь.

Например:

```swift
protocol UpdateProfileNameUseCaseProtocol {
    func execute(_ profileName: String) async
}

final class UpdateProfileNameUseCase: UpdateProfileNameUseCaseProtocol {
    private var apiClient = APIClient()
    
    func execute(_ profileName: String) async {
        await apiClient.updateProfileName(profileName)
    }
}
```

В этом упрощенном примере приводится действие `UpdateProfileName`, которое в целом легко представить с точки зрения пользовательского сценария. Скорее всего, оно происходит где-то на экране настроек профиля и вызывает когда пользователь заполняет поле имени в своём профиле и нажимает кнопку обновить. 

В чем польза такой абстракции, если она “всего лишь” оборачивает вызов API?

На самом деле от такой абстракции много явной и неявной пользы:

- Абстрагирует презентационный слой от источников данных, тем самым разрывая сильную связь между двумя слоями.
- Повышает тестируемость предоставляя возможность точечно подменять реализацию.
- Так же подмена реализации позволяет ускорить процесс разработки давая возможность “не дожидаться” готовности API, или позволяет протестировать различные сценарии, которые сложно воспроизвести с реальным API.

Эта простая, но важная абстракция может в целом сильно улучшить итоговое качество кода в вашем application/domain слое. 

### Repository

Другой “удобной” абстракцией может быть паттерн Repository, который абстрагирует работу с конкретным предметным источником данных и может выполнять роль оркестрации запросов к этому источнику данных, маппингу, хэндлингу ошибок, кэшированию. 

Далее этот репозиторий можно использовать из конкретных UseCase-ов.

Например рассмотрим ситуацию, когда мы разрабатываем приложение с элементами геймификации, где есть понятие “карты уровней”, которые пользователь может приходить. Логика генерации и прохождения уровней реализована на бэкенде, и взаимодействие с ней происходит с помощью отдельного сервиса `MapService`. 

Мы можем добавить поверх этого сервиса слой репозитория, чтобы абстрагировать маппинг, дедубликацию запросов, кэширование.

```swift
final class MapRepository {
    private var service: MapService
    private var map = Map.empty
    // Сохраняем текущий запрос по обновлению карту, чтобы избежать дубликатов
    private var mapFetchingTask: Task<Map, Error>?
    
    @discardableResult
    func getMap(force: Bool = false) async throws -> Map {
        // Если карта пустая -> запрашиваем новую карту
        if map.isEmpty {
            let newMap = try await fetchMap()
            map = newMap
            return map
        // Если требуется форсированное обновление карты,
        // то мы запрашиваем новую и склеиваем её с текущей картой.
        // Потому что текущая карта может отличаться, т.к. юзер
        // может проходить карту оффлайн.
        } else if force {
            let newMap = try await fetchMap()
            map.merge(with: newMap)
            return map
        // Если уже есть запрос на обновление карты, 
        // мы возвращаем этот запрос, тем самым не дублируя его.
        } else if let mapFetchingTask = mapFetchingTask {
            return try await mapFetchingTask.value
        } else {
        // И как базовый кейс, мы просто возвращаем закэшированный в памяти вариант.
            return map
        }
    }
    
    func getLevel(_ number: MapLevel.Number) async throws -> MapLevel {
        // Если запрошенного уровня нету на карте, значит он еще не пройден
        // и у нас нет по нему информации
        guard let level = map[number] else {
            throw MapError.nonPassedLevelIsRequested
        }
        return try await fetchLevel(number) 
    }
    
    func passLevel(_ number: MapLevel.Number, stagePassDto: MapStagePassDTO) async throws -> MapLevel {
        defer {
            // На всякий случай, каждый раз когда
            // уровень "проходится" триггерим синхронизиацию всей карты
            syncMap()
        }
        // Проверяем, что этот номер уровня валидный.
        try await safetyCheck(for: number)
        // Делаем запрос на бэкенд, который отметит уровень как пройденный
        let dto = try await service.passStage(dto: stagePassDto)
        let level = MapLevel(with: dto)
        // Обновляем локальный кэш с данными свеже-пройденного уровня.
        map[number] = level
        return level
    }
    
    // Синхронизируем локально закэшированную версию карты с бэкендом
    private func syncMap() {
        Task {
            let newMap = try await fetchMap()
            map.merge(with: newMap)
        }
    }
    
    private func fetchMap() async throws -> Map {
        if let mapFetchingTask = mapFetchingTask {
            let map = try await mapFetchingTask.value
            return map
        }
        mapFetchingTask = Task.detached(priority: .userInitiated) { [unowned self] in
            defer {
                mapFetchingTask = nil
            }
            let pagedDto = try await self.service.getMapStages(page: 1, pageSize: 1000)
            return Map(with: pagedDto.content)
        }
        return try await mapFetchingTask!.value
    }
    
    private func fetchLevel(_ number: Int) async throws -> MapLevel {
        try await safetyCheck(for: number)
        let dto = try await service.getMapStage(stageNumber: number)
        let level = MapLevel(with: dto)
        map[number] = level
        return level
    }
    
    private func safetyCheck(for levelNumber: MapLevel.Number) async throws {
        if map.isEmpty {
            try await getMap(force: true)
        }
        if !map[levelNumber].isExist {
            throw MapError.nonPassedLevelIsRequested
        }
    }
}
```

Как видно из этого примера – абстракция поверх конкретного сервиса / источника данных в виде репозитория может быть очень полезна в определенных сценариях. 

Один из плюсов такого репозитория в том, что код, который находится в нём обычно highly cohesive, то есть очень согласованно решает одну проблему. В этом случае это работа с сущностью карты.

Очень частый распространенный [code smell](https://refactoring.guru/refactoring/smells) в кодовых базах iOS приложений – это неявные зависимости от глобальных объектов типа: `DataManager.shared.getSomething`. 
Комбинация UseCase + Repository + DI неплохо может развязывать этот клубок.

Другим хорошим случаем для применения этого паттерна является авторизация, где так же можно абстрагировать все связанные вызовы, сохранение токена и т.д. в единый `AuthRepository`.

## DI

**DI** (Dependency Injection), **DIP** (Dependency Inversion Principle), **IoC** (inversion of Control) это три отдельные темы для обсуждения, для более корректного и глубокого понимания этой темы внизу этой статьи будут приложены ресурсы для изучения.

В этой же секции мы будем рассматривать более прагматичную пользу, которую можно получить от DI даже в местных реалиях, с сжатыми сроками и вечной нехваткой времени и желания для написания тестов. 

Чем же DI полезен на ежедневной основе:

- Даёт легкий инструмент для достижения слабой связанности частей системы, и вынуждает более осознанно подходит к проектированию границ и интерфейсов общения между ними.
    - Без DI: гораздо легче просто взять и сделать прямой вызов в глобальный объект типа `DataManager.shared.getSomething` тем самым создав неявную прямую зависимость между вызывающим модулем и глобальным объектом.
    - Используя DI: легко отделить момент создания зависимости, момент её внедрения и зависимость не от конкретной версии зависимости, а от интерфейса, тем самым открыв двери ряду возможностей по типу мокинга зависимостей (как для разработки, так и для тестирования).
- При настроенной, эргономичной системе внедрения зависимостей в ваши объекты, становится гораздо легче и “кайфовее” писать слабосвязанный код без необходимости ручного внедрения через конструкторы, и перекладывания зависимостей сверху вниз с помощью конструкторов.
- Когда вы внедряете зависимости в ваши объекты посредством инъекций, вы начинаете более осознанных думать о зависимостях, делать неявные зависимости явными тем самым улучшая качество кода, сопровождаемость (потому что как минимум класс в котором все зависимости явно указаны, гораздо легче понять, чем класс где все “втихаря” хотят куда-то в глобальные объекты).

В этом проекте в виде DI контейнера используется [Factory](https://github.com/hmlongco/Factory/), очень легковесная, детально задокументированная библиотека. Все необходимые детали и объяснения, примеры использования можно найти в документации. 

Вопросы по типу “Что именно регистрировать в контейнер?”, “В какой момент дробить контейнеры на множество маленьких контейнеров?” остаются на усмотрение и интуицию команды разработки. Самое важное не увлекаться, не вдаваться в крайности и использовать DI контейнер так, чтобы он рос вместе с вами и приносил вам пользу (а не создавал проблемы).

## Navigation

Навигация – одна из самых недооцененных задач, которую должна решать прагматичная iOS архитектура. Так как навигация часто идёт бок-о-бок с DI, связана с созданием и внедрением зависимостей – это может стать ключевым местом в проекте где вы либо а) всё “разруливаете” по местам либо б) “завариваете” непонятную кашу. 

Благо довольно давно придумали эффективный выход из ситуации в виде вспомогательной сущности в лице `Coordinator`-ов. Координаторы доказали себя как полезная абстракция, и широко используются в проектах разных размеров. 

Но, к сожалению, их использование идёт с набором определенных ограничений, с которыми приходится мириться и писать сопроводительный код, чтобы всю эту затею поддерживать. Помимо этого, из коробки координаторы не предлагают решений для глобальный навигации (например: сложные диплинки, модификация стэка) и часто становятся той самой “дырявой абстракцией” (leaky abstraction) в которую протекают те ответственности, которые ей не принадлежат. 

К счастью, чуваки из HeadHunter основательно подошли к решению вопроса навигации в iOS и написали крутой библиотеку [Nivelir](https://github.com/hhru/Nivelir), которая не является дизайн паттерном, а скорее очень гибкой и расширяемой абстракции поверх нативного стэка навигационных компонентов (UINavigationController, UIWindow, UITabBarController и т.д.). 

Эта библиотека никак не диктует как именно вам её использовать, поэтому она хорошо комбинируется с уже известными паттернами типа координатора, при этом избавляя разработчиков от надобности написания огромного количество поддерживающего бойлерплейт кода.

Главной сложностью при работе с координатором было то, что нужно было управлять памятью самостоятельно (`addChildCoordinator`, `removeChildCoordinator` и т.д.), так как нам нужно было чтобы координаторы знали о друг-друге, могли показывать друг-друга и при этом чтобы память не утекала. 

При работе с Nivelir, нам не нужно заботиться о памяти, потому что навигация теперь строится глобально (всегда идёт от рутового Window), а не локально (как с координаторами, когда нужно было постоянно явно задавать кто и как кого может показать).

Пример использования координатора вместе с Nivelir-овским navigator-ом.

```swift
class AuthCoordinator {
    @Injected(\.navigator) var navigator
    @Injected(\.screens) var screens

    func start() {
        let route = ScreenWindowRoute()
            .setRoot(
                to: screens
                    .enterUsernameScreen()
                    .withStackContainer()
            )
            .makeKeyAndVisible()
        
        navigator.navigate(to: route)
    }

    func onEnterUsernameNextDidTap(container: UIViewController) {
        let screen = AuthEnterPasswordViewController()
        navigator.navigate(from: container) { route in
            route
                .stack
                .push(screen)
        }

    }

    func onEnterPasswordNextDidTap(container: UIViewController) {
        navigator.navigate(from: container) { route in
            route
                .stack
                .clear(animation: .crossDissolve)
                .push(screens.homeScreen(), animation: .crossDissolve)
        }
    }
}
```

На самом деле, для большинства простых сценариев показа, можно не выделять отдельные Coordinator-ы, как мы привыкли это делать, а напрямую навигировать экраны с других контроллеров. Если же нам нужно переиспользовать показ какого-то экрана в определенных условиях, например: экран авторизации для входа в авторизационную зону или экран ввода пин-кода при входе в защищенную зону – то это всё можно делать в Nivelir с помощью кастомных `ScreenAction` (подробнее можно почитать у них в документации). 

Помимо этого отсутствие координаторов, или их использование в новом виде будет дисциплинировать процесс разработки не позволяя протекать какой-то бизнес-логике, которую “удобно можно было положить в координатор”, хотя координатору о ней знать не нужно. 

# Рекомендации

Пару общих рекомендаций по жизни с этой (и в принципе любой) архитектурой:

- **Архитектура должна расти и эволюционировать вместе с развитием проекта и команды.** То, что сегодня подходит для команды, которая решает задачу А в составе 3 человек, скорее всего будет трещать по швам, когда команда уже будет решать задачу ААА* в составе 30 человек. Всегда держите руку на пульсе и спрашивайте себя – можете ли вы как-то улучшить то, с чем вы работаете каждый день: ваша архитектура, инфраструктура, абстракции.
- **Не следуйте рекомендациям вслепую.** Все так называемые “бест практисы” идут всегда со своим контекстом, который очень часто опускается и не учитывается. То, что является “бест практисом” для задачи с контекстом А, может являться смертоносным решением для задачи с контекстом B. Так же и этот проект не более чем рекомендация и начальный фундамент поверх которого можно строить, либо менять части этого фундамента.
- **Задавайте вопросы. Идите в глубину.** Пытайтесь понять почему были приняты какие-то решения и сделаны какие-то трейд-оффы. Построение хороших систем это всегда про трейд-оффы: ускорение процесса сборки посредством модуляризации → зато надобность поддерживать новый модульный сетап проекта; следование всем правилам “чистых” и “теоритически правильных” подходов → повышенных порог входа для разработчиков с рынка, надобность доп. обучения;
- **Используйте мощь инфраструктуры и тулзов чтобы повышать продуктивность  команды.** Tuist для управления проектами. Inject для HotReload-а. Pulse для просмотра логов. SwiftGen/Sourcery для кодо-генерации. Proxyman для дебаггинга и инспекции сетевых запросов. Эти все инструменты могут сэкономить вашей команде много времени, а так же повысить удовольствие получаемого от процесса разработки.

Более специфичные рекомендации касательно реализации:

- Лучше рефакторить из монолита в сторону многомодульности инкрементально по мере роста, нежели чем начинать сразу с модуляризированным сетапом. Есть пару вещей, которые можно соблюдать сначала чтобы легче было модуляризировать в будущем:
    - В явном виде задавать public модификаторы доступа. Потому что когда всё уйдет по модулям, internal будет недоступен вне модуля.
    - Думать о зависимостях между модулями с самого начала – проектировать правильные контракты и интерфейсы, вовремя создавать правильные child DI контейнеры.
- Если появляются какие-то магические отступы при работе с SwiftUI вьюшками в UIKit контроллерах – то это скорее всего UIHostingController добавляет не нужные safe area insets, иметь ввиду.
- Когда со временем обрисуется примерный набор файлов, которые постоянно создаются по шаблону во время работы: модуль (view, viewcontroller, store, viewmodel) или usecase (protocol + implementation + mock) – самое время это вынести в `.stencil` шаблоны и генерировать с помощью команды `tuist scaffold`
- Для реализации Auth Guarded экрана: когда каждый раз при заходе в авторизованную зону выходит модалка, которая требует авторизации – посмотреть пример `ScreenAuthorizeAction` из [Nivelir/Example](https://github.com/hhru/Nivelir/tree/main/Example/NivelirExample/Routing/Authorization) проекта.

# Ресурсы

- Как проектировать табуретку https://habr.com/ru/post/276593/
- Viable ios architecture https://medium.com/@iamirzhan/the-only-viable-ios-architecture-c42f7b4c845d
- MVC is not your problem https://www.youtube.com/watch?v=A1vzcxR-Ss0
- DI, IoC, DiP https://podlodka.io/3
