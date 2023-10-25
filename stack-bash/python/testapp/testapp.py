from flask import Flask, render_template
import mariadb
import psycopg2

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        mariadb.connect(host="127.0.0.1", database="test", user="test_u", password="Test123")
        mariadb_color="green"
        mariadb_message="CONNECTÉ AVEC SUCCÈS"
    except:
        mariadb_color="red"
        mariadb_message="CONNEXION ÉCHOUÉE"

    try:
        psycopg2.connect("host='127.0.0.1' dbname='test' user='test_u' password='Test123'")
        postgresql_color="green"
        postgresql_message="CONNECTÉ AVEC SUCCÈS"
    except:
        postgresql_color="red"
        postgresql_message="CONNEXION ÉCHOUÉE"

    return render_template(
        'index.html',
        mariadb_color=mariadb_color,
        mariadb_message=mariadb_message,
        postgresql_color=postgresql_color,
        postgresql_message=postgresql_message)


if __name__ == "__main__":
    app.run()
