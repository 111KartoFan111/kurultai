```
my_flask_app/
├── app.py                    # Главный файл приложения
├── config.py                 # Настройки приложения
├── extensions.py             # Подключение расширений (SQLAlchemy, JWT и т. д.)
├── models.py                 # ORM-модели для базы данных
├── services/                 # Бизнес-логика
│   ├── __init__.py
│   ├── auth_service.py       # Авторизация и регистрация
│   ├── admin_service.py      # Логика админ панели
│   ├── game_service.py       # Управление играми
│   ├── user_service.py       # Управление участниками
│   ├── report_service.py     # Генерация отчетов
├── routes/                   # Маршруты (по модулям)
│   ├── __init__.py
│   ├── auth_routes.py        # Маршруты для авторизации
│   ├── admin_routes.py       # Маршруты админ панели
│   ├── user_routes.py        # Маршруты для пользователя
│   ├── game_routes.py        # Маршруты для игр
│   ├── profile_routes.py     # Личный кабинет
│   ├── report_routes.py      # Маршруты для отчетов
├── templates/                # Шаблоны (рендеринг на сервере)
│   ├── base.html             # Базовый шаблон
│   ├── auth/
│   │   ├── login.html        # Страница логина
│   │   ├── register.html     # Страница регистрации
│   ├── admin/                # Шаблоны для админ панели
│   │   ├── dashboard.html    # Панель администратора
│   │   ├── newgame.html      # Создание игры
│   │   ├── usermanage.html   # Управление пользователями
│   │   ├── newevent.html     # Создание мероприятия
│   │   ├── reports.html      # Отчеты
│   ├── user/                 # Шаблоны для пользовательской панели
│   │   ├── profile.html      # Личный кабинет пользователя
│   │   ├── newcommand.html   # Создание команды
│   │   ├── events.html       # Список мероприятий
│   │   ├── reports.html      # Отчеты
├── static/                   # Статические файлы (CSS, изображения)
│   ├── css/
│   │   ├── admin/            # Стили для админ панели
│   │   │   ├── dashboard.css # Стили для страницы панели администратора
│   │   │   ├── newgame.css   # Стили для страницы создания игры
│   │   │   ├── usermanage.css # Стили для страницы управления пользователями
│   │   │   ├── newevent.css  # Стили для страницы создания мероприятия
│   │   │   ├── reports.css   # Стили для страницы отчетов
│   │   ├── user/             # Стили для пользовательской панели
│   │   │   ├── profile.css   # Стили для страницы профиля пользователя
│   │   │   ├── newcommand.css    # Стили для страницы создания команды
│   │   │   ├── events.css        # Стили для страницы мероприятий
│   │   │   └── reports.css       # Стили для страницы отчетов
│   │   ├── common/           # Общие стили
│   │   │   └── common.css    # Общие стили
│   ├── img/                  # Изображения
│   │   ├── logo.png
│   │   ├── background.jpg
│   └── fonts/                # Шрифты
│       └── custom-font.woff
├── migrations/               # Миграции базы данных
│   ├── versions/             # Файлы миграций
│   └── alembic.ini           # Конфигурация Alembic
├── README.md                 # Документация
├── requirements.txt          # Зависимости Python
├── .env                      # Переменные окружения
└── wsgi.py                   # Точка входа для WSGI-сервера
```
