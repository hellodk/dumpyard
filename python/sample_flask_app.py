from flask import Flask
app = Flask(__name__)

app = Flask(__name__)

@app.route('/')
def start():
    return "Hello from 8080 server"

@app.route('/projects/')
def projects():
    return 'The project page from 8080 server'

@app.route('/about')
def about():
    return 'The about page from 8080 server'

if __name__ == "__main__":
    app.debug = True
    app.run(host='127.0.0.1', port=8080, debug=True)
