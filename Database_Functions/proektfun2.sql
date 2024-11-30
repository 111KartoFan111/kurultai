--user панель
--профиль
CREATE OR REPLACE FUNCTION update_user_profile_user(
    p_user_id INT,
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
    WHERE user_id = p_user_id;

    RETURN 'Профиль пользователя успешно обновлен';
END;
$$ LANGUAGE plpgsql;

--обновленние пароля 
CREATE OR REPLACE FUNCTION update_user_password_user(
    p_user_id INT,
    p_old_password_hash VARCHAR,
    p_new_password_hash VARCHAR
) RETURNS TEXT AS $$
DECLARE
    current_password_hash VARCHAR;
BEGIN
    SELECT password_hash
    INTO current_password_hash
    FROM users
    WHERE user_id = p_user_id;

    IF current_password_hash <> p_old_password_hash THEN
        RETURN 'Старый пароль введен неверно';
    END IF;

    UPDATE users
    SET password_hash = p_new_password_hash
    WHERE user_id = p_user_id;

    RETURN 'Пароль успешно обновлен';
END;
$$ LANGUAGE plpgsql;


--создать команду
CREATE OR REPLACE FUNCTION create_team(
    p_team_name VARCHAR,
    p_creator_id INT,
    p_league VARCHAR,
    p_members JSON
) RETURNS TEXT AS $$
DECLARE
    new_team_id INT;
    member_name TEXT; 
BEGIN
    INSERT INTO Teams (name, created_at)
    VALUES (p_team_name, CURRENT_TIMESTAMP)
    RETURNING team_id INTO new_team_id;
    IF p_league NOT IN ('Русская', 'Казахская', 'Английская') THEN
        RETURN 'Неверно указана лига. Допустимые значения: Русская, Казахская, Английская.';
    END IF;
    INSERT INTO UserTeams (user_id, team_id)
    VALUES (p_creator_id, new_team_id);

    FOR member_name IN SELECT json_array_elements_text(p_members) LOOP
        INSERT INTO Users (full_name, role)
        VALUES (member_name, 'team_member');

        INSERT INTO UserTeams (user_id, team_id)
        VALUES (currval('users_user_id_seq'), new_team_id);
    END LOOP;
    RETURN 'Команда успешно создана';
END;
$$ LANGUAGE plpgsql;


--получение данных о командах
CREATE OR REPLACE FUNCTION get_teams_info() 
RETURNS TABLE (
    team_id INT,
    team_name VARCHAR,
    num_members INT,
    creator_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.team_id,
        t.name AS team_name,
        COUNT(ut.user_id) AS num_members,
        u.username AS creator_name
    FROM Teams t
    JOIN UserTeams ut ON t.team_id = ut.team_id
    JOIN Users u ON ut.user_id = u.user_id
    WHERE u.role = 'creator'
    GROUP BY t.team_id, t.name, u.username;
END;
$$ LANGUAGE plpgsql;


--редак инфо о команде
CREATE OR REPLACE FUNCTION update_team(
    p_team_id INT,
    p_new_team_name VARCHAR DEFAULT NULL,
    p_new_league VARCHAR DEFAULT NULL,
    p_new_members JSON DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    member_name TEXT;
BEGIn
    UPDATE Teams
    SET 
        name = CASE WHEN p_new_team_name IS NOT NULL THEN p_new_team_name ELSE name END
    WHERE team_id = p_team_id;
    IF p_new_league IS NOT NULL THEN
        IF p_new_league NOT IN ('Русская', 'Казахская', 'Английская') THEN
            RETURN 'Неверно указана лига. Допустимые значения: Русская, Казахская, Английская.';
        END IF;
    END IF;
    IF p_new_members IS NOT NULL THEN
        DELETE FROM UserTeams WHERE team_id = p_team_id;
        FOR member_name IN SELECT json_array_elements_text(p_new_members) LOOP
            INSERT INTO Users (full_name, role)
            VALUES (member_name, 'team_member');
            INSERT INTO UserTeams (user_id, team_id)
            VALUES (currval('users_user_id_seq'), p_team_id); -- currval используется для получения последнего ID
        END LOOP;
    END IF;

    RETURN 'Команда успешно обновлена';
END;
$$ LANGUAGE plpgsql;


--удаление команды
CREATE OR REPLACE FUNCTION delete_team(p_team_id INT) RETURNS TEXT AS $$
BEGIN
    DELETE FROM UserTeams WHERE team_id = p_team_id;
    DELETE FROM Teams WHERE team_id = p_team_id;

    RETURN 'Команда успешно удалена';
END;
$$ LANGUAGE plpgsql;


--мероприятия 
CREATE TABLE EventRegistrations (
    registration_id SERIAL PRIMARY KEY,
    event_id INT REFERENCES Events(event_id) ON DELETE CASCADE,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    team_id INT REFERENCES Teams(team_id) ON DELETE SET NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--вывод мероприятий , которые еще не состоялись 
CREATE OR REPLACE FUNCTION get_upcoming_events() 
RETURNS TABLE (
    event_id INT,
    name VARCHAR,
    description TEXT,
    league VARCHAR,
    event_date TIMESTAMP,
    location VARCHAR,
    judge VARCHAR,
    organizer_name VARCHAR,
    max_teams INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.event_id,
        e.name,
        e.description,
        e.league,
        e.event_date,
        e.location,
        e.judge,
        u.full_name AS organizer_name,
        e.max_teams
    FROM Events e
    JOIN Users u ON e.organizer_id = u.user_id
    WHERE e.event_date > CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;


--рег на мероприятия 
CREATE OR REPLACE FUNCTION register_for_event(
    p_event_id INT,
    p_user_id INT,
    p_team_id INT DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    current_team_count INT;
BEGIn
    IF NOT EXISTS (SELECT 1 FROM Events WHERE event_id = p_event_id) THEN
        RETURN 'Мероприятие не найдено';
    END IF;

  
    SELECT COUNT(DISTINCT team_id) 
    INTO current_team_count
    FROM EventRegistrations
    WHERE event_id = p_event_id;

    IF current_team_count >= (SELECT max_teams FROM Events WHERE event_id = p_event_id) THEN
        RETURN 'Максимальное количество команд уже зарегистрировано';
    END IF;
    INSERT INTO EventRegistrations (event_id, user_id, team_id)
    VALUES (p_event_id, p_user_id, p_team_id);

    RETURN 'Регистрация на мероприятие успешно выполнена';
END;
$$ LANGUAGE plpgsql;




--отчеты
--получение трех послед игр
CREATE OR REPLACE FUNCTION get_last_three_games(p_user_id INT) 
RETURNS TABLE (
    match_id INT,
    tournament_name VARCHAR,
    event_date TIMESTAMP,
    league VARCHAR,
    num_teams INT,
    location VARCHAR,
    judge VARCHAR,
    winner VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.match_id,
        t.name AS tournament_name,
        m.match_date AS event_date,
        tm.league,
        COUNT(DISTINCT ut.team_id) AS num_teams,
        m.location,
        m.judge,
        CASE
            WHEN r1.score > r2.score THEN 'Оппозиция'
            WHEN r1.score < r2.score THEN 'Правительство'
            ELSE 'Ничья'
        END AS winner
    FROM Matches m
    JOIN Tournaments t ON m.tournament_id = t.tournament_id
    JOIN Teams tm ON m.team1_id = tm.team_id OR m.team2_id = tm.team_id
    LEFT JOIN UserTeams ut ON tm.team_id = ut.team_id
    LEFT JOIN Results r1 ON r1.match_id = m.match_id AND r1.team_id = m.team1_id
    LEFT JOIN Results r2 ON r2.match_id = m.match_id AND r2.team_id = m.team2_id
    WHERE ut.user_id = p_user_id AND m.match_date < CURRENT_TIMESTAMP
    GROUP BY m.match_id, t.name, tm.league, m.match_date, m.location, m.judge, r1.score, r2.score
    ORDER BY m.match_date DESC
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;



--получение всех прошедших игр
CREATE OR REPLACE FUNCTION get_all_past_games() 
RETURNS TABLE (
    match_id INT,
    tournament_name VARCHAR,
    event_date TIMESTAMP,
    league VARCHAR,
    num_teams INT,
    location VARCHAR,
    judge VARCHAR,
    winner VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.match_id,
        t.name AS tournament_name,
        m.match_date AS event_date,
        tm.league,
        COUNT(DISTINCT ut.team_id) AS num_teams,
        m.location,
        m.judge,
        CASE
            WHEN r1.score > r2.score THEN 'Оппозиция'
            WHEN r1.score < r2.score THEN 'Правительство'
            ELSE 'Ничья'
        END AS winner
    FROM Matches m
    JOIN Tournaments t ON m.tournament_id = t.tournament_id
    JOIN Teams tm ON m.team1_id = tm.team_id OR m.team2_id = tm.team_id
    LEFT JOIN UserTeams ut ON tm.team_id = ut.team_id
    LEFT JOIN Results r1 ON r1.match_id = m.match_id AND r1.team_id = m.team1_id
    LEFT JOIN Results r2 ON r2.match_id = m.match_id AND r2.team_id = m.team2_id
    WHERE m.match_date < CURRENT_TIMESTAMP
    GROUP BY m.match_id, t.name, tm.league, m.match_date, m.location, m.judge, r1.score, r2.score
    ORDER BY m.match_date DESC;
END;
$$ LANGUAGE plpgsql;



