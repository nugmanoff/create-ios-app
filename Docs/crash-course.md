# Краш-курс по Мобильной Архитектуре

## Развеивание мифов

Перед тем как погрузиться в объяснение выбранного архитектурного подхода, стоит сделать краткое введение по “выбору хорошей архитектуры”.

Это довольно острый вопрос в мире мобильной разработки, и есть много устоявшихся подходов и паттернов: MVC, MVVM, VIPER, Clean, UDF (Redux, TCA), и есть столько же мнений и разногласий на этот счёт. 

Каждый из этих подходов придуман с определённым упором на решение тех или иных проблем. Следовательно самое важное понять какие проблемы мы решаем нашим кодом и какая архитектура может нам помочь с этим эффективное всего. 

Все последующие размышления и выводы будут основываться на теории того, что в энтерпрайз мобильных приложениях зачастую большая часть *бизнес логики*, которая нацелена на решение проблемы будет реализовано на *бэкенде*. Следовательно мобильное приложение будет являться *клиентом* для взаимодействия с этим решением. Такие приложения называют *тонкий клиент (”Thin Client”).* 

Многие традционные архитектуры нацелены на проектирование доменного слоя (бизнес логики), его разделения от презентационного слоя и т.д. Что само по себе показало крайне эффективным подходом к проектированию. Проблемы возникают в тот момент, когда по разным причинам люди начинают называть бизнес логикой или доменным слоем то, что таковым не является. 

Если представить нашу систему как единое решение, которое ориентировано на решение бизнес-проблемы, то можно понять что само по себе понятие *мобильного* *клиента (сlient)* или *приложения (application)* подсказывает нам о том, на каком уровне абстракции мы в основном работаем. 

В случае с *тонким клиентом,* можно представить себе что в принципе, Domain в большинстве своём отсутствует на клиенте, т.к. он представлен на бэкенде и клиент это больше про показ (Presentation) и взаимодействие (Application) с доменным слоем, который реализован на бэкенде.

![domain-driven-design-layers.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c275f97a-1d87-4d78-a6de-8a8d074de97c/domain-driven-design-layers.png)

Как упомяналось раннее, традиционные архитектуры большое внимание уделяют проектированию доменного слоя и изоляции слоев друг от друга. В случае клиент-серверной архитектуры это происходит посредством API-контрактов и взаимодействию с помощью транспортного слоя (HTTP).

Означает ли это, что на тонком клиенте нету никакой логики? Совсем нет, но нужно четко понимать, где находится решение ключевой проблемы и не создавать “вымышленную сложность” пытаясь придумать доменный слой там, где его нет. Как говорится: “в конце концов мы просто вызываем REST API метод и парсим JSON 😄”. 

Тут возникает следующий вопрос в голове мобильных разработчиков, если всё так просто – то куда девать мозги? Куда девать все эти паттерны и крутые приёмы которым мы научились? И к сожалению, эти вопросы зачастую приводят к созданию, а потом к решению “вымышленных проблем”.

Это было небольшой введение про то, как мобильным разработчиком свойственно выдавать желаемое за действительное и решать вымышленные проблемы. 

В следующей же секции мы постараемся понять как решать реальные проблемы. 

## Решение реальных проблем

Из этого следует, что всё “интересное” происходит на бэкенде, а на мобилке “мы просто вьюшки рисуем”? 

На самом деле не всё такое черно-белое, как может показаться, и на каждом из этапов и слоев решения бизнес-проблемы есть свои сложности. И это зависит от природы самой проблемы, и конкретного подхода к решению, которым предполагается закрыть эту проблему. Для кого-то это означает *тонкий клиент*, для кого-то *толстый клиент,* для кого-то это рендеринг темплейтов и вебвью напрямую с бэкенда.

Возвращаясь к нашему предположению, что большинство энтерпрайз мобильных приложений является тонкими клиентами, то основной сложностью становится ни что иное как:

- State Management

Так как мобильные приложения существуют в окружении, отчасти контролиуемым (непредсказуемым) пользователем, количество возможных состояний системы и различных факторов, которые могут повлиять на неё растут экспоненциально в отличие от тех же бэкенд систем, взаимодействия с которыми в основном происходит по защищенному каналу и формально утвержденному контракту (API). 

Некий контракт взаимодействия пользователя с приложением так же существует в виде событий нажатия на экран, датчиков движения и т.п., но этот контракт намного менее строгий, что и порождает большее количество сложности которым нужно управлять. 

Это зачастую и является основной сложностью при разработки мобильных приложений и описывается одним широким термином – State Management. 

Сюда можно отнести множество вопросов/проблемы, которые нужно учитывать при разработке:

- Что будет если человек закроет приложение в этот момент? (И это может произойти абсолютно в любой момент жизни приложения).
- Что будет если человек нажмёт на кнопку и начнётся передача данных и у него посреди процесса “отвалится интернет”?
- Что будет если человек нажмёт на кнопку не один раз (”как он должен”), а 3 раза?
- Что будет если человек не дожидаясь завершения загрузки выйдет с какого-то экрана и попытается обратно зайти?
- Что будет если у человека заполнится память и ОС “убьет” процесс вашего приложения?

И таких вопросов великое множество, и ответы на них звучат очень просто, потому что интуитивно мы все, как пользователи мобильных устройств, понимаем что хотим видеть от приложений:

- Чтобы приложение ничего “не забывало” (Пример: я заполнял длинную форму, закрыл приложение и через 3 часа зашел, чтобы всё было на своих местах).
- Чтобы приложение было предсказуемым несмотря на то, как бы непредсказуемо я бы с ним не работал (Пример: Я закрыл экран, на котором было сказано “не закрывайте экран, оплата в процессе…”, потому что мне захотелось и я хочу чтобы всё было чики-пуки).
- Чтобы приложение всегда “самовосстанавливалось” (Пример: у меня отвалился интернет, села батарейка, и т.д. – я хочу чтобы когда я обратно зашел в приложение у меня оно вернулось до состояния в котором я его покинул).

Для того, чтобы эффективно решать все вышеописанные проблемы – очень важно проектировать управление состоянием приложения корректным образом. Как раз-таки на этом и фокусируется большинство последних идей и подходов в мобильной архитектуре (пример: [The Composable Architecture](https://www.pointfree.co/collections/composable-architecture)).

Помимо этого всего, архитектура мобильного приложения должна иметь все другие, более общие [свойства хорошей архитектуры](https://habr.com/ru/articles/276593/): 

- Гибкость.
- Расширяемость.
- Сопровождаемость.
- Тестируемость.
- Масштабируемость.
