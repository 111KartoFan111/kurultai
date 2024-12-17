```
my_flask_app/
├── app.py                     Главный файл приложения
├── config.py                  Настройки приложения
├── extensions.py              Подключение расширений (SQLAlchemy)
├── models.py                  ORM-модели для базы данных
├── templates/                 Шаблоны (рендеринг на сервере)
│   ├── auth/
│   │   ├── login.html         Страница входа
│   │   ├── register.html      Страница регистрации
│   ├── admin/                 Шаблоны для админ панели
│   │   ├── apminprofile.html     Панель администратора
│   │   ├── newgame.html       Создание игры
│   │   ├── usermanage.html    Управление пользователями
│   │   ├── newevent.html      Создание мероприятия
│   │   ├── adminreports.html  Отчеты
│   ├── user/                  Шаблоны для пользовательской панели
│   │   ├── userprofile.html       Личный кабинет пользователя
│   │   ├── newcommand.html    Создание команды
│   │   ├── events.html        Список мероприятий
│   │   ├── userreports.html   Отчеты
├── static/                    Статические файлы (CSS, JS, изображения)
│   ├── css/
│   │   ├── login.css  Стили для страницы входа
│   │   ├── login.css  Стили для страницы регистрации
│   │   ├── admin/             Стили для админ панели
│   │   │   ├── adminprofile.css  Стили для страницы панели администратора
│   │   │   ├── newgame.css    Стили для страницы создания игры
│   │   │   ├── usermanage.css  Стили для страницы управления пользователями
│   │   │   ├── newevent.css   Стили для страницы создания мероприятия
│   │   │   ├── adminreports.css    Стили для страницы отчетов
│   │   ├── user/              Стили для пользовательской панели
│   │   │   ├── userprofile.css    Стили для страницы профиля пользователя
│   │   │   ├── teams.css     Стили для страницы создания команды
│   │   │   ├── events.css         Стили для страницы мероприятий
│   │   │   └── reports.css        Стили для страницы отчетов
│   ├── img/                   Изображения
├── README.md                  Документация
├── requirements.txt           Зависимости Python
```



```
заполнение отчета админ


from flask import Flask, render_template, request
import sqlite3

app = Flask(__name__)

 SQLite database setup
DATABASE = 'league_data.db'

 Function to connect to the SQLite database
def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

 Initialize the database and create the table
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
    init_db()   Initialize the database when starting the application
    app.run(debug=True)
```




```

pip install Flask-SQLAlchemy

```

```

from datetime import datetime
from extensions import db

class User(db.Model):
    __tablename__ = 'users'
    user_id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    full_name = db.Column(db.String(100))
    gender = db.Column(db.String(10))
    phone_number = db.Column(db.String(15))
    group_num = db.Column(db.String(50))
    date_of_birth = db.Column(db.Date)
    last_active = db.Column(db.DateTime)
    role = db.Column(db.String(20), default='user')
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    is_active = db.Column(db.Boolean, default=True)

class UsersRank(db.Model):
    __tablename__ = 'users_rank'
    rank_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete='CASCADE'))
    rank_name = db.Column(db.String(50), nullable=False)
    points = db.Column(db.Integer, default=0)

class Tournament(db.Model):
    __tablename__ = 'tournaments'
    tournament_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    winner_team_id = db.Column(db.Integer, db.ForeignKey('teams.team_id', ondelete='SET NULL'), nullable=True)

class Team(db.Model):
    __tablename__ = 'teams'
    team_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Game(db.Model):
    __tablename__ = 'games'
    game_id = db.Column(db.Integer, primary_key=True)
    topic = db.Column(db.String(255), nullable=False)
    max_participants = db.Column(db.Integer, nullable=False)
    game_date = db.Column(db.Date, nullable=False)
    game_time = db.Column(db.Time, nullable=False)
    location = db.Column(db.String(255), nullable=False)
    judge_id = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete='SET NULL'))
    winner_team_id = db.Column(db.Integer, db.ForeignKey('teams.team_id', ondelete='SET NULL'), nullable=True)
    is_finished = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    tournament_id = db.Column(db.Integer, db.ForeignKey('tournaments.tournament_id', ondelete='SET NULL'), nullable=True)
    league_id = db.Column(db.Integer, db.ForeignKey('leagues.league_id', ondelete='SET NULL'), nullable=True)

    winner_team = db.relationship('Team', backref='games', passive_deletes=True)

class Event(db.Model):
    __tablename__ = 'events'
    event_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    event_date = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(255))
    created_by = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete='SET NULL'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    winner_team_id = db.Column(db.Integer, db.ForeignKey('teams.team_id', ondelete='SET NULL'), nullable=True)

class EventRegistration(db.Model):
    __tablename__ = 'event_registrations'
    registration_id = db.Column(db.Integer, primary_key=True)
    event_id = db.Column(db.Integer, db.ForeignKey('events.event_id', ondelete='CASCADE'))
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete='CASCADE'))
    team_id = db.Column(db.Integer, db.ForeignKey('teams.team_id', ondelete='SET NULL'))
    registered_at = db.Column(db.DateTime, default=datetime.utcnow)

class Result(db.Model):
    __tablename__ = 'results'
    result_id = db.Column(db.Integer, primary_key=True)
    game_id = db.Column(db.Integer, db.ForeignKey('games.game_id', ondelete='CASCADE'))
    team_id = db.Column(db.Integer, db.ForeignKey('teams.team_id', ondelete='CASCADE'))
    score = db.Column(db.Integer, nullable=False)

class League(db.Model):
    __tablename__ = 'leagues'
    league_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)

class Notification(db.Model):
    __tablename__ = 'notifications'
    notification_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete='CASCADE'))
    message = db.Column(db.Text, nullable=False)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class EventNotification(db.Model):
    __tablename__ = 'event_notifications'
    notification_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id', ondelete='CASCADE'))
    event_id = db.Column(db.Integer, db.ForeignKey('events.event_id', ondelete='CASCADE'))
    message = db.Column(db.Text, nullable=False)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
```

```
-- Добавляем колонку для 1-го спикера и связываем с users.user_id
ALTER TABLE teams 
ADD COLUMN speaker_1 INT,
ADD CONSTRAINT fk_speaker_1 FOREIGN KEY (speaker_1) REFERENCES users(user_id) ON DELETE SET NULL;

-- Добавляем колонку для 2-го спикера и связываем с users.user_id
ALTER TABLE teams 
ADD COLUMN speaker_2 INT,
ADD CONSTRAINT fk_speaker_2 FOREIGN KEY (speaker_2) REFERENCES users(user_id) ON DELETE SET NULL;

-- Добавляем колонку для очков команды
ALTER TABLE teams 
ADD COLUMN team_points INT DEFAULT 0;
```
