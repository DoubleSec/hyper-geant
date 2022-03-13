from flask import Flask, render_template, jsonify, request, make_response

from . import db

import datetime
import uuid

app = Flask(__name__)

# Daily seed generator.
@app.route("/_get_seed")
def get_seed():
    nums = datetime.date.today().isocalendar()
    seed = [nums[0] // 256, nums[0] % 256, nums[1], nums[2]]
    return jsonify(result=seed)


@app.route("/_get_user_best")
def get_user_best():

    db_ = db.get_db()
    r_uuid = request.cookies.get("uuid")
    cur_date = datetime.date.today().isoformat()

    best = db.get_user_best(db_, r_uuid, cur_date)
    return jsonify(result=best)


@app.route("/_set_time")
def set_time():
    name = request.args.get("name", type=str)
    time = request.args.get("time", type=float)
    cur_date = datetime.date.today().isoformat()
    r_uuid = request.cookies.get("uuid")

    db_ = db.get_db()
    db.put_time(db_, name, r_uuid, cur_date, time)
    return jsonify(time=time)


@app.route("/_get_times")
def get_times():
    cur_date = datetime.date.today().isoformat()

    db_ = db.get_db()
    times = db.get_times(db_, cur_date)
    return jsonify(times=times)


# Actual page
@app.route("/")
def index():

    resp = make_response(render_template("index.html"))

    # Set a cookie.
    r_uuid = request.cookies.get("uuid")
    c_uuid = uuid.uuid4().hex if r_uuid is None else r_uuid

    if r_uuid is None:
        print(f"Setting new cookie: {c_uuid}")
    else:
        print(f"Re-setting cookie with uuid: {r_uuid}")
    resp.set_cookie("uuid", c_uuid)

    return resp
