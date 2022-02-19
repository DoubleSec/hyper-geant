from flask import Flask, render_template, jsonify

import datetime

app = Flask(__name__)


@app.route("/_get_seed")
def get_seed():
    nums = datetime.date.today().isocalendar()
    seed = [nums[0] // 256, nums[0] % 256, nums[1], nums[2]]
    return jsonify(result=seed)


@app.route("/")
def index():
    return render_template("index.html")
