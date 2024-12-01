-- Таблица user
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
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

-- Индексы для улучшения производительности
--CREATE INDEX idx_users_email ON Users(email);
--CREATE INDEX idx_notifications_user_id ON Notifications(user_id);
--CREATE INDEX idx_matches_tournament_id ON Matches(tournament_id);
