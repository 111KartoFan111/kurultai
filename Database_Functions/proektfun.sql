select * from Users


CREATE OR REPLACE FUNCTION register_user(
    p_username VARCHAR,
    p_email VARCHAR,
    p_phone_number VARCHAR,
    p_password_hash VARCHAR
) RETURNS TEXT AS $$
BEGIN
    -- Проверяем, существует ли уже пользователь с таким email
    IF EXISTS (SELECT 1 FROM Users WHERE email = p_email) THEN
        RETURN 0;
    ELSE
        -- Если email не найден, добавляем нового пользователя
        INSERT INTO Users (username, email, phone_number, password_hash)
        VALUES (p_username, p_email, p_phone_number, p_password_hash);
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION login_user(
    p_username VARCHAR,
    p_password_hash VARCHAR
) RETURNS TEXT AS $$
DECLARE
    user_count INTEGER;
BEGIN
    -- Проверяем, существует ли пользователь с таким username и password_hash
    SELECT COUNT(*)
    INTO user_count
    FROM users
    WHERE username = p_username AND password_hash = p_password_hash;
    -- Если совпадение найдено
    IF user_count > 0 THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION login_user_with_role(
    p_username VARCHAR,
    p_password_hash VARCHAR
) RETURNS TEXT AS $$
DECLARE
    user_role VARCHAR;
BEGIN
    SELECT role
    INTO user_role
    FROM users
    WHERE username = p_username AND password_hash = p_password_hash;
    IF FOUND THEN
        RETURN role;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

--панель админа , ПРОФИЛЬ
--обновление пароля
CREATE OR REPLACE FUNCTION update_user_password(
    p_username VARCHAR,
    p_old_password_hash VARCHAR,
    p_new_password_hash VARCHAR
) RETURNS TEXT AS $$
DECLARE
    current_password_hash VARCHAR;
BEGIN
    SELECT password_hash
    INTO current_password_hash
    FROM users
    WHERE username = p_username;

    IF current_password_hash <> p_old_password_hash THEN
        RETURN 'Старый пароль введен неверно';
    END IF;
    UPDATE users
    SET password_hash = p_new_password_hash
    WHERE username = p_username;
    RETURN 'Пароль успешно обновлен';
END;
$$ LANGUAGE plpgsql;


--изменение профиля(case, чтоб можно было изменить один элемент , а не все )
CREATE OR REPLACE FUNCTION update_user_profile(
    p_username VARCHAR,
    p_full_name VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_gender VARCHAR DEFAULT NULL,
    p_phone_number VARCHAR DEFAULT NULL,
    p_group_num VARCHAR DEFAULT NULL,
    p_date_of_birth DATE DEFAULT NULL
) RETURNS TEXT AS $$
BEGIN
    UPDATE users
    SET 
        full_name = CASE WHEN p_full_name IS NOT NULL THEN p_full_name ELSE full_name END,
        email = CASE WHEN p_email IS NOT NULL THEN p_email ELSE email END,
        gender = CASE WHEN p_gender IS NOT NULL THEN p_gender ELSE gender END,
        phone_number = CASE WHEN p_phone_number IS NOT NULL THEN p_phone_number ELSE phone_number END,
        group_num = CASE WHEN p_group_num IS NOT NULL THEN p_group_num ELSE group_num END,
        date_of_birth = CASE WHEN p_date_of_birth IS NOT NULL THEN p_date_of_birth ELSE date_of_birth END
    WHERE username = p_username;
    RETURN 'Профиль успешно обновлен';
END;
$$ LANGUAGE plpgsql;

--ПРОФИЛЬ конец


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


--админ панель , управление играми 
--функция для создания игры
CREATE OR REPLACE FUNCTION create_game(
    p_topic VARCHAR,
    p_max_participants INT,
    p_game_date DATE,
    p_game_time TIME,
    p_location VARCHAR,
    p_league_id INT,
    p_judge_id INT
) RETURNS TEXT AS $$
BEGIN
    INSERT INTO Games (
        topic, 
        max_participants, 
        game_date, 
        game_time, 
        location, 
        league_id, 
        judge_id
    ) VALUES (
        p_topic, 
        p_max_participants, 
        p_game_date, 
        p_game_time, 
        p_location, 
        p_league_id, 
        p_judge_id
    );
    RETURN 'Игра успешно создана';
END;
$$ LANGUAGE plpgsql;

--получение списка всех игр
CREATE OR REPLACE FUNCTION get_all_games()
RETURNS TABLE (
    game_id INT,
    topic VARCHAR,
    max_participants INT,
    game_date DATE,
    game_time TIME,
    location VARCHAR,
    league_name VARCHAR,
    judge_name VARCHAR,
    is_finished BOOLEAN,
    winner_team_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        g.game_id,
        g.topic,
        g.max_participants,
        g.game_date,
        g.game_time,
        g.location,
        t.name AS league_name,
        u.full_name AS judge_name,
        g.is_finished,
        tm.name AS winner_team_name
    FROM Games g
    LEFT JOIN Tournaments t ON g.league_id = t.tournament_id
    LEFT JOIN Users u ON g.judge_id = u.user_id
    LEFT JOIN Teams tm ON g.winner_team_id = tm.team_id
    ORDER BY g.game_date, g.game_time;
END;
$$ LANGUAGE plpgsql;



--обновление информации об игре
CREATE OR REPLACE FUNCTION update_game(
    p_game_id INT,
    p_topic VARCHAR DEFAULT NULL,
    p_max_participants INT DEFAULT NULL,
    p_game_date DATE DEFAULT NULL,
    p_game_time TIME DEFAULT NULL,
    p_location VARCHAR DEFAULT NULL
) RETURNS TEXT AS $$
BEGIN
    UPDATE Games
    SET 
        topic = COALESCE(p_topic, topic),
        max_participants = COALESCE(p_max_participants, max_participants),
        game_date = COALESCE(p_game_date, game_date),
        game_time = COALESCE(p_game_time, game_time),
        location = COALESCE(p_location, location)
    WHERE game_id = p_game_id;

    RETURN 'Информация об игре успешно обновлена';
END;
$$ LANGUAGE plpgsql;


--завершение игры и определение победителя
CREATE OR REPLACE FUNCTION finish_game(
    p_game_id INT,
    p_winner_team_id INT
) RETURNS TEXT AS $$
BEGIN
    UPDATE Games
    SET 
        is_finished = TRUE,
        winner_team_id = p_winner_team_id
    WHERE game_id = p_game_id;

    RETURN 'Игра успешно завершена и победитель определен';
END;
$$ LANGUAGE plpgsql;


--удалить игру если она не прошла 
CREATE OR REPLACE FUNCTION delete_game(p_game_id INT)
RETURNS TEXT AS $$
BEGIN
    DELETE FROM Games
    WHERE game_id = p_game_id
      AND is_finished = FALSE;

    RETURN 'Игра успешно удалена (если она не была завершена)';
END;
$$ LANGUAGE plpgsql;


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


--управление участниками админ панель
--выведеие всех участников 
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (
    username VARCHAR,
    email VARCHAR,
    last_active DATE,
    role VARCHAR,
    rank_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.username,
        u.email,
        u.created_at::DATE AS last_active, 
        u.role,
        ur.rank_name
    FROM Users u
    LEFT JOIN UsersRank ur ON u.user_id = ur.user_id
    ORDER BY u.username;
END;
$$ LANGUAGE plpgsql;




--изменение ранга 
CREATE OR REPLACE FUNCTION update_user_rank(user_id INT, new_rank VARCHAR)
RETURNS VOID AS $$
BEGIN
    INSERT INTO UsersRank (user_id, rank_name)
    VALUES (user_id, new_rank)
    ON CONFLICT (user_id) DO UPDATE
    SET rank_name = new_rank;
END;
$$ LANGUAGE plpgsql;

--удаление пользователя
CREATE OR REPLACE FUNCTION delete_user(user_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM UsersRank WHERE user_id = user_id;
    DELETE FROM Users WHERE user_id = user_id;
END;
$$ LANGUAGE plpgsql;


--обновление последнего входа
CREATE OR REPLACE FUNCTION update_last_active(user_id INT)
RETURNS VOID AS $$
BEGIN
    UPDATE Users
    SET created_at = CURRENT_TIMESTAMP
    WHERE user_id = user_id;
END;
$$ LANGUAGE plpgsql;



--мероприятия 
--создание мероприятия 
CREATE OR REPLACE FUNCTION create_event(
    event_name VARCHAR(100), 
    event_description TEXT, 
    event_date TIMESTAMP, 
    location VARCHAR(255), 
    created_by INT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Events (name, description, event_date, location, created_by)
    VALUES (event_name, event_description, event_date, location, created_by);
END;
$$ LANGUAGE plpgsql;

--получение послед 3 мероприятий 
CREATE OR REPLACE FUNCTION get_last_three_events()
RETURNS TABLE (
    event_id INT, 
    name VARCHAR(100), 
    description TEXT, 
    event_date TIMESTAMP, 
    location VARCHAR(255), 
    created_by INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.event_id, e.name, e.description, e.event_date, e.location, e.created_by
    FROM Events e
    ORDER BY e.event_date DESC
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;


--изменения мероприятия 
CREATE OR REPLACE FUNCTION update_event(
    event_id INT,
    new_name VARCHAR(100), 
    new_description TEXT, 
    new_event_date TIMESTAMP, 
    new_location VARCHAR(255)
)
RETURNS VOID AS $$
BEGIN
    UPDATE Events
    SET 
        name = new_name,
        description = new_description,
        event_date = new_event_date,
        location = new_location
    WHERE event_id = event_id;
END;
$$ LANGUAGE plpgsql;

--удаление мероприятия 
CREATE OR REPLACE FUNCTION delete_event(event_id INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Events WHERE event_id = event_id;
END;
$$ LANGUAGE plpgsql;


--отчеты
CREATE OR REPLACE FUNCTION get_last_three_games_per_league()
RETURNS TABLE (
    league_name VARCHAR,
    game_topic VARCHAR,
    number_of_teams INT,
    location VARCHAR,
    judge_name VARCHAR,
    winner_team_name VARCHAR
) AS $$
BEGIN
    -- Казахская лига
    RETURN QUERY
    SELECT 
        'Казахская' AS league_name,
        g.topic AS game_topic,
        COUNT(t.team_id) AS number_of_teams,
        g.location AS location,
        u.username AS judge_name,
        CASE 
            WHEN r.team_id = g.team1_id THEN t1.name
            WHEN r.team_id = g.team2_id THEN t2.name
            ELSE 'Нет победителя'
        END AS winner_team_name
    FROM Games g
    LEFT JOIN Results r ON r.game_id = g.game_id
    LEFT JOIN Users u ON u.user_id = g.judge_id
    LEFT JOIN Teams t1 ON t1.team_id = g.team1_id
    LEFT JOIN Teams t2 ON t2.team_id = g.team2_id
    LEFT JOIN Teams t ON t.team_id = r.team_id
    WHERE g.league_id = 1 -- Казахская лига
    AND g.is_finished = TRUE
    GROUP BY g.game_id, g.topic, g.location, u.username, r.team_id, t1.name, t2.name
    ORDER BY g.game_date DESC
    LIMIT 1;

    -- Русская лига
    RETURN QUERY
    SELECT 
        'Русская' AS league_name,
        g.topic AS game_topic,
        COUNT(t.team_id) AS number_of_teams,
        g.location AS location,
        u.username AS judge_name,
        CASE 
            WHEN r.team_id = g.team1_id THEN t1.name
            WHEN r.team_id = g.team2_id THEN t2.name
            ELSE 'Нет победителя'
        END AS winner_team_name
    FROM Games g
    LEFT JOIN Results r ON r.game_id = g.game_id
    LEFT JOIN Users u ON u.user_id = g.judge_id
    LEFT JOIN Teams t1 ON t1.team_id = g.team1_id
    LEFT JOIN Teams t2 ON t2.team_id = g.team2_id
    LEFT JOIN Teams t ON t.team_id = r.team_id
    WHERE g.league_id = 2 -- Русская лига
    AND g.is_finished = TRUE
    GROUP BY g.game_id, g.topic, g.location, u.username, r.team_id, t1.name, t2.name
    ORDER BY g.game_date DESC
    LIMIT 1;

    -- Английская лига
    RETURN QUERY
    SELECT 
        'Английская' AS league_name,
        g.topic AS game_topic,
        COUNT(t.team_id) AS number_of_teams,
        g.location AS location,
        u.username AS judge_name,
        CASE 
            WHEN r.team_id = g.team1_id THEN t1.name
            WHEN r.team_id = g.team2_id THEN t2.name
            ELSE 'Нет победителя'
        END AS winner_team_name
    FROM Games g
    LEFT JOIN Results r ON r.game_id = g.game_id
    LEFT JOIN Users u ON u.user_id = g.judge_id
    LEFT JOIN Teams t1 ON t1.team_id = g.team1_id
    LEFT JOIN Teams t2 ON t2.team_id = g.team2_id
    LEFT JOIN Teams t ON t.team_id = r.team_id
    WHERE g.league_id = 3 -- Английская лига
    AND g.is_finished = TRUE
    GROUP BY g.game_id, g.topic, g.location, u.username, r.team_id, t1.name, t2.name
    ORDER BY g.game_date DESC
    LIMIT 1;

END;
$$ LANGUAGE plpgsql;







 




select * from Users
