-- Таблица user
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    gender VARCHAR(10),
    phone_number VARCHAR(15),
    group_num VARCHAR(50),
    date_of_birth DATE,
    last_active TIMESTAMP,
    role VARCHAR(20) DEFAULT 'user', -- user, admin, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Таблица рангов userov
CREATE TABLE UsersRank (
    rank_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    rank_name VARCHAR(50) NOT NULL,
    points INT DEFAULT 0
);

-- Таблица турниров
CREATE TABLE Tournaments (
    tournament_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица команды
CREATE TABLE Teams (
    team_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица матчей
CREATE TABLE Matches (
    match_id SERIAL PRIMARY KEY,
    tournament_id INT REFERENCES Tournaments(tournament_id) ON DELETE CASCADE,
    team1_id INT REFERENCES Teams(team_id) ON DELETE SET NULL,
    team2_id INT REFERENCES Teams(team_id) ON DELETE SET NULL,
    match_date TIMESTAMP NOT NULL,
    location VARCHAR(255)
);

-- Таблица результатов
CREATE TABLE Results (
    result_id SERIAL PRIMARY KEY,
    match_id INT REFERENCES Matches(match_id) ON DELETE CASCADE,
    team_id INT REFERENCES Teams(team_id) ON DELETE CASCADE,
    score INT NOT NULL
);

-- Таблица мероприятий
CREATE TABLE Events (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    event_date TIMESTAMP NOT NULL,
    location VARCHAR(255),
    created_by INT REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Таблица уведомлений
CREATE TABLE Notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Связь пользователей и команд
CREATE TABLE UserTeams (
    user_team_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    team_id INT REFERENCES Teams(team_id) ON DELETE CASCADE
);

-- Таблица для хранения токенов восстановления паролей
CREATE TABLE PasswordResetTokens (
    token_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица игр
CREATE TABLE Games (
    game_id SERIAL PRIMARY KEY,
    topic VARCHAR(255) NOT NULL,
    max_participants INT NOT NULL,
    game_date DATE NOT NULL,
    game_time TIME NOT NULL,
    location VARCHAR(255) NOT NULL,
    league_id INT REFERENCES Tournaments(tournament_id) ON DELETE SET NULL,
    judge_id INT REFERENCES Users(user_id) ON DELETE SET NULL,
    winner_team_id INT REFERENCES Teams(team_id) ON DELETE SET NULL,
    is_finished BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица лиг

CREATE TABLE Leagues (
    league_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO Leagues (name)
VALUES ('russian'), ('kazakh'), ('english');

ALTER TABLE Games
ADD CONSTRAINT fk_league
FOREIGN KEY (league_id) REFERENCES Leagues(league_id)
ON DELETE SET NULL;

-- Таблица регистарции на мероприятия
CREATE TABLE EventRegistrations (
    registration_id SERIAL PRIMARY KEY,
    event_id INT REFERENCES Events(event_id) ON DELETE CASCADE,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    team_id INT REFERENCES Teams(team_id) ON DELETE SET NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Индексы для улучшения производительности
--CREATE INDEX idx_users_email ON Users(email);
--CREATE INDEX idx_notifications_user_id ON Notifications(user_id);
--CREATE INDEX idx_matches_tournament_id ON Matches(tournament_id);



-- Insert 
INSERT INTO Users (email, phone_number, full_name, gender, date_of_birth, group_num, username, password_hash)
VALUES 
('bakosyatt567@gmail.com', '87719815739', 'Тәсібек Бағнұр Таңатарқызы', 'Жен', '1999-01-23', 'ПО2402', 'Dionysius', 'SlavaBobu'),
('danelya_sm@icloud.com', '+77478480952', 'Смагулова Данеля Меллатовна', 'Жен', '2009-05-02', 'ПО2402', 'danelyasm', 'danelya09'),
('szarina08@icloud.com', '87786281309', 'Сайдалина Зарина Ерлановна', 'Жен', '2008-11-06', 'ПО-2402', 'Zara', 'Zara2008'),
('ailisabandhi789@gmail.com', '87761666358', 'Сабанчи Айли Ериккызы', 'Жен', '2008-06-18', 'ПО 2406', 'ailisshka', 'sabanchi'),
('panchenkoamina@gmail.com', '+77053821335', 'Панченко Амина Андреевна', 'Жен', '2006-04-03', 'ПО2303', 'Aminferrr', 'aminA2025.'),
('anel94544@gmail.com', '+77775451177', 'Калыкулова Анель Муратовна', 'Жен', '2007-09-04', 'ПО2303', 'Анель', 'Anel'),
('azhar208asko@gmail.com', '87051032460', 'Зұлхарнай Ажар', 'Жен', '2008-07-10', '2402', 'azhar', '?'),
('zhumataymahfuza@icloud.com', '87478403626', 'Жұматай Махфуза Мұратқызы', 'Жен', '2008-09-13', 'По 2405', 'Sulybelle', 'mmm555!'),
('asirbekselin@gmail.com', '+77002709670', 'Әшірбек Селин Әлібекқызы', 'Жен', '2007-08-21', 'ПО-2301', 'mortualin', 'astana2020@'),
('erkezhanabil@gmail.com', '87789134110', 'Әбіл Еркежан Бағдатқызы', 'Жен', '2009-09-30', 'ПО2402', 'erkezhan.ab', 'Karavana19/'),
('rmiscuteliololoyo@gmail.com', '+77785749181', 'Адилова Адина Алмазовна', 'Жен', '2007-04-09', 'ПО2306', '9nrj4', 'qwerty12345'),
('znurlanuly203@gmail.com', '87073804075', 'Тойшыбаев Жаслан', 'Муж', '2008-03-18', 'ПО-2303', 'ENTER', '180308tjN'),
('sunkaruly@proton.me', '+77718444254', 'Сакенов Ануар Сункарулы', 'Муж', '2008-05-13', 'ПО-2302', 'Anek', 'AnuarSunkarovich_A8'),
('makazanalpamys@gmail.com', '87058758185', 'Мақажан Алпамыс Мұхамедқалиұлы', 'Муж', '2008-08-11', 'ПО 2309', 'Alpamys', 'Alpamys123'),
('kystaubainurbakyt@icloud.com', '87758050335', 'Қыстаубай Нұрбахыт Серікұлы', 'Муж', '2008-09-30', '2405', 'nurym', 'abc123@/'),
('zarkynismagulov@gmail.com', '87762538632', 'Исмагулов Жарқын Маратұлы', 'Муж', '2007-08-27', 'ПО-2301', 'KartoFan', 'pezve4-tydtiB-zonfar'),
('disaisa01@gmail.com', '87764996998', 'Исин Диас Оразұлы', 'Муж', '2007-07-16', 'ПО-2304', 'Isin_Dias', 'i5india$'),
('Ermohind@gmail.com', '87000228000', 'Ермохин Данил Дмитриевич', 'Муж', '2008-04-30', 'ПО 2306', 'Benito_big_boy', 'Aska2008'),
('erahmedkz16@mail.ru', '+77471630707', 'Ермек Ахмед', 'Муж', '2007-07-02', 'ПО2303', 'rxsdf', 'fara#24');

UPDATE Users
SET role = 'admin'
WHERE email IN ('bakosyatt567@gmail.com', 'zarkynismagulov@gmail.com', 'asirbekselin@gmail.com', 'sunkaruly@proton.me');

select * from Users 

-- Создаем пользователей
CREATE ROLE "Dionysius" LOGIN PASSWORD 'SlavaBobu';
CREATE ROLE "KartoFan" LOGIN PASSWORD 'pezve4-tydtiB-zonfar';
CREATE ROLE "mortualin" LOGIN PASSWORD 'astana2020@';
CREATE ROLE "Anek" LOGIN PASSWORD 'AnuarSunkarovich_A8';

-- Назначаем суперпользователями
ALTER ROLE "Dionysius" WITH SUPERUSER;
ALTER ROLE "KartoFan" WITH SUPERUSER;
ALTER ROLE "mortualin" WITH SUPERUSER;
ALTER ROLE "Anek" WITH SUPERUSER;





-- Добавление столбца tournament_id в таблицу games
ALTER TABLE games
ADD COLUMN tournament_id INT,
ADD CONSTRAINT fk_tournament
    FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id) 
    ON DELETE SET NULL;

-- Добавление столбца league_id в таблицу games
ALTER TABLE games
ADD COLUMN league_id INT,
ADD CONSTRAINT fk_league_games
    FOREIGN KEY (league_id) REFERENCES leagues(league_id)
    ON DELETE SET NULL;

-- Добавление столбца league_id в таблицу tournaments
ALTER TABLE tournaments
ADD COLUMN league_id INT,
ADD CONSTRAINT fk_league_tournaments
    FOREIGN KEY (league_id) REFERENCES leagues(league_id)
    ON DELETE SET NULL;
