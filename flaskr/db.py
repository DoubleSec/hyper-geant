import sqlite3
import uuid

from flask import current_app, g


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect("app.db")

        # Create the tables we need if they don't exist.
        cur = g.db.cursor()
        cur.execute(
            "CREATE TABLE IF NOT EXISTS times (name text, uuid text, date text, time real);"
        )
        cur.execute("CREATE TABLE IF NOT EXISTS users (uuid text, name text);")
        g.db.commit()
        cur.close()

    return g.db


def put_time(db, name, r_uuid, date, time):

    cur = db.cursor()

    cur.execute("INSERT INTO times VALUES (?, ?, ?, ?)", (name, r_uuid, date, time))
    db.commit()

    cur.execute(
        """
    DELETE FROM times 
    WHERE uuid = :uuid 
      AND date = :date 
      AND time > (SELECT MIN(time) FROM times WHERE uuid = :uuid AND date = :date)""",
        {"date": date, "uuid": r_uuid},
    )
    db.commit()


def get_user_best(db, r_uuid, date):

    cur = db.cursor()

    cur.execute(
        "SELECT * FROM times WHERE uuid = :uuid AND date = :date",
        {"uuid": r_uuid, "date": date},
    )

    res = cur.fetchone()
    print(res)
    return res


def get_times(db, date):

    cur = db.cursor()
    print(f"Querying for: {date}")
    cur.execute("SELECT * FROM times WHERE date = :date ORDER BY time", {"date": date})
    return cur.fetchall()


def close_db():
    db = g.pop("db", None)

    if db is not None:
        db.close()


def init_app(app):
    app.teardown_appcontext(close_db)
