import os
class Config:
    SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:0000@localhost:5433/proekt'  # Замените на реальные данные
    SQLALCHEMY_TRACK_MODIFICATIONS = False  # Отключение отслеживания изменений
    SECRET_KEY = '0a62bb60bdd01454aab92052412d7300921f5d11101127b678020be955f5e4ad'  # Секретный ключ для сессий
