from flask import Flask, render_template, redirect, url_for, request, session, flash, send_file
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import os
import io
import pandas as pd
from models import User, Tournament, Game, Event, Team, Match, Result, UsersRank,League
from config import Config
from extensions import db

app = Flask(__name__)

# Настройка конфигурации приложения
app.config.from_object(Config)

# Инициализация базы данных
db.init_app(app)

# Включите маршрут для логина
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user and check_password_hash(user.password_hash, password):
            session['user_id'] = user.user_id
            session['role'] = user.role
            if user.role == 'admin':
                return redirect(url_for('admin_profile'))
            else:
                return redirect(url_for('user_profile'))
        else:
            flash('Неверный логин или пароль', 'danger')
    return render_template('auth/login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        phone_number = request.form['phone']

        # Проверка на наличие уже существующего пользователя с таким логином
        if User.query.filter_by(username=username).first():
            flash('Логин уже занят', 'danger')
            return redirect(url_for('register'))

        # Проверка на наличие уже зарегистрированной почты
        if User.query.filter_by(email=email).first():
            flash('Почта уже зарегистрирована', 'danger')
            return redirect(url_for('register'))

        # Валидация пароля (например, минимальная длина)
        if len(password) < 8:
            flash('Пароль должен быть не менее 8 символов', 'danger')
            return redirect(url_for('register'))

        # Хэширование пароля
        password_hash = generate_password_hash(password)

        # Создание нового пользователя
        new_user = User(username=username, password_hash=password_hash, email=email, phone_number=phone_number)
        db.session.add(new_user)
        db.session.commit()

        # Отправка успешного сообщения
        flash('Регистрация прошла успешно!', 'success')
        return redirect(url_for('login'))

    return render_template('auth/register.html')

@app.route('/adminprofile')
def admin_profile():
    user = User.query.get(session['user_id'])
    return render_template('admin/adminprofile.html', user=user)

@app.route('/creategame', methods=['GET', 'POST'])
def create_game():
    # Получаем все лиги и судей из базы данных
    leagues = League.query.all()
    judges = User.query.filter_by(role='judge').all()  # Судьи (по роли)
    if request.method == 'POST':
        topic = request.form['topic']
        max_participants = request.form['max_participants']
        game_date = request.form['game_date']
        game_time = request.form['game_time']
        location = request.form['location']
        league_id = request.form.get('league_id')  # Получаем ID лиги
        judge_id = request.form.get('judge_id')  # Получаем ID судьи

        # Проверяем, что league_id и judge_id не пустые
        if not league_id or not judge_id:
            flash('Все поля обязательны!', 'danger')
            return render_template('admin/creategame.html', leagues=leagues, judges=judges)

        # Преобразуем game_date в формат даты и game_time в формат времени
        try:
            game_date = datetime.strptime(game_date, '%Y-%m-%d').date()
            game_time = datetime.strptime(game_time, '%H:%M').time()
        except ValueError:
            flash('Неверный формат даты или времени', 'danger')
            return render_template('admin/creategame.html', leagues=leagues, judges=judges)

        # Создаем новую игру
        new_game = Game(
            topic=topic,
            max_participants=max_participants,
            game_date=game_date,
            game_time=game_time,
            location=location,
            league_id=league_id,
            judge_id=judge_id
        )
        db.session.add(new_game)
        db.session.commit()

        flash('Игра успешно создана!', 'success')
        return redirect(url_for('create_game'))  # Перенаправляем на страницу создания игры

    return render_template('admin/creategame.html', leagues=leagues, judges=judges)

@app.route('/adminreport', methods=['GET'])
def admin_report():
    games = Game.query.order_by(Game.created_at.desc()).limit(3).all()
    # Генерация отчета в Excel
    data = []
    for game in games:
        data.append({
            'topic': game.topic,
            'game_date': game.game_date,
            'location': game.location,
            'winner_team': game.winner_team_id
        })
    df = pd.DataFrame(data)
    output = io.BytesIO()
    df.to_excel(output, index=False)
    output.seek(0)
    return send_file(output, attachment_filename="report.xlsx", as_attachment=True)


if __name__ == '__main__':
    app.run(debug=True)
