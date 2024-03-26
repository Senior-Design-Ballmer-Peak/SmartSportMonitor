from flask import Flask, render_template, Response

app = Flask(__name__)

@app.route('/')
def index():
    # Render a template which will show the scores, puck speed, and other analytics
    return render_template('index.html')

@app.route('/score')
def score():
    # Endpoint to update score, should accept data and update the score variable
    pass

@app.route('/puck_speed')
def puck_speed():
    # Endpoint to update puck speed, should accept data and update the speed variable
    pass

@app.route('/live_feed')
def live_feed():
    # Use OpenCV or another library to capture live feed and stream
    pass


@app.route('/replay')
def replay():
    # Use OpenCV or another library to capture replays
    pass

if __name__ == '__main__':
    app.run(debug=True)
