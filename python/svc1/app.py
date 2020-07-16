from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)


@app.route("/")
def load_home_page():
    return ('Hello from Service 1')


if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=8086, debug=True)
