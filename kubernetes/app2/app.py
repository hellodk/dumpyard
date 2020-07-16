from flask import Flask, render_template, request, redirect, url_for
import requests
import json

app = Flask(__name__)

svc1_port = '8086'
port = '8087'
svc_name = "svc1"
# svc_name = 'localhost'
ep = '/svc1'

# url = (("http://%s:" % svc_name) + svc1_port)
url = (svc_name + ":" + svc1_port)


@app.route("/")
def load_home_page():
    return ('Hello from Service 2')


@app.route("/svc1")
def call_svc1():
    '''
    Calling svc 1
    '''
    print (url)
    resp = requests.get(url)
    data = resp.content
    return data


if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=port, debug=True)
