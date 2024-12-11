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
    __tablename__ = 'UsersRank'
    rank_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('Users.user_id', ondelete='CASCADE'))
    rank_name = db.Column(db.String(50), nullable=False)
    points = db.Column(db.Integer, default=0)

class Tournament(db.Model):
    __tablename__ = 'Tournaments'
    tournament_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

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
    winner_team_id = db.Column(db.Integer, db.ForeignKey('teams.team_id', ondelete='SET NULL'), nullable=True)  # ID победившей команды
    is_finished = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    league_id = db.Column(db.Integer, db.ForeignKey('tournaments.tournament_id', ondelete='SET NULL'), nullable=True)


    # Используем правильное имя класса Team
    winner_team = db.relationship('Team', backref='games', passive_deletes=True)




class Event(db.Model):
    __tablename__ = 'Events'
    event_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    event_date = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(255))
    created_by = db.Column(db.Integer, db.ForeignKey('Users.user_id', ondelete='SET NULL'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
class Match(db.Model):
    __tablename__ = 'Matches'
    match_id = db.Column(db.Integer, primary_key=True)
    tournament_id = db.Column(db.Integer, db.ForeignKey('Tournaments.tournament_id', ondelete='CASCADE'))
    team1_id = db.Column(db.Integer, db.ForeignKey('Teams.team_id', ondelete='SET NULL'))
    team2_id = db.Column(db.Integer, db.ForeignKey('Teams.team_id', ondelete='SET NULL'))
    match_date = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(255))

class Result(db.Model):
    __tablename__ = 'Results'
    result_id = db.Column(db.Integer, primary_key=True)
    match_id = db.Column(db.Integer, db.ForeignKey('Matches.match_id', ondelete='CASCADE'))
    team_id = db.Column(db.Integer, db.ForeignKey('Teams.team_id', ondelete='CASCADE'))
    score = db.Column(db.Integer, nullable=False)


class League(db.Model):
    __tablename__ = 'leagues'  # Обратите внимание, что это строка, указывающая на имя таблицы
    league_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
