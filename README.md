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
├── static/                   # Статические файлы (CSS, JS, изображения)
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
│   ├── js/
│   │   ├── admin/            # JS для админ панели
│   │   │   ├── dashboard.js  # JS для страницы панели администратора
│   │   │   ├── newgame.js    # JS для страницы создания игры
│   │   │   ├── usermanage.js # JS для страницы управления пользователями
│   │   │   ├── newevent.js   # JS для страницы создания мероприятия
│   │   │   ├── reports.js    # JS для страницы отчетов
│   │   ├── user/             # JS для пользовательской панели
│   │   │   ├── profile.js    # JS для страницы профиля пользователя
│   │   │   ├── newcommand.js # JS для страницы создания команды
│   │   │   ├── events.js     # JS для страницы мероприятий
│   │   │   └── reports.js    # JS для страницы отчетов
│   │   └── common/           # Общие скрипты
│   │       └── common.js     # Общие скрипты для всех страниц
│   ├── img/                  # Изображения
│   │   ├── logo.png
│   │   ├── background.jpg
├── migrations/               # Миграции базы данных
│   ├── versions/             # Файлы миграций
│   └── alembic.ini           # Конфигурация Alembic
├── README.md                 # Документация
├── requirements.txt          # Зависимости Python
├── .env                      # Переменные окружения
└── wsgi.py                   # Точка входа для WSGI-сервера
```



```
заполнение отчета админ


from flask import Flask, render_template, request
import sqlite3

app = Flask(__name__)

# SQLite database setup
DATABASE = 'league_data.db'

# Function to connect to the SQLite database
def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

# Initialize the database and create the table
def init_db():
    with get_db() as conn:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS leagues (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                liga TEXT NOT NULL,
                team_count INTEGER NOT NULL,
                location TEXT NOT NULL,
                judge TEXT NOT NULL,
                victory TEXT NOT NULL
            )
        ''')
        conn.commit()

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/save", methods=["POST"])
def save_data():
    liga = request.form.get("liga")
    team_count = request.form.get("team_count")
    location = request.form.get("location")
    judge = request.form.get("judge")
    victory = request.form.get("victory")
    
    with get_db() as conn:
        conn.execute('''
            INSERT INTO leagues (liga, team_count, location, judge, victory)
            VALUES (?, ?, ?, ?, ?)
        ''', (liga, team_count, location, judge, victory))
        conn.commit()
    
    message = "Данные успешно сохранены!"
    return render_template("index.html", message=message)

if __name__ == "__main__":
    init_db()  # Initialize the database when starting the application
    app.run(debug=True)
```
