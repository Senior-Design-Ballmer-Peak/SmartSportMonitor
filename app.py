import time
from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Set a secret key for sessions

# Use the 'certificate' function to load your Firebase service account
cred = credentials.Certificate('/Users/charleswilmot/Documents/GitHub/SmartSportMonitor/ssm-csu-firebase-adminsdk-qvu64-a7af4114b9.json')

# Initialize your Firebase instance with the credentials
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://ssm-csu-default-rtdb.firebaseio.com'
})

@app.route('/')
def index():
    game_started = session.get('game_started', False)

    # Initialize a context dictionary with default values
    context = {
        'player1': session.get('player1', 'No one'),
        'player2': session.get('player2', 'No one'),
        'game_started': game_started,
        'active_game': False,
        'p1': 0,
        'p2': 0,
        'puck_in_frame': False,
        'puck_speed': 0,
        'in_frame': False,
        'rad': 0,
        'speed': 0,
        'x': 0,
        'y': 0
    }

    if game_started:
        # Fetch all game data from Firebase if a game is active
        game_data_ref = db.reference('game_data')
        game_data = game_data_ref.get()
        if game_data:  # If game_data is not None
            context.update(game_data)

    return render_template('index.html', **context)

@app.route('/start_game', methods=['GET', 'POST'])
def start_game():
    if request.method == 'POST':
        # Store the player names in session
        session['player1'] = request.form.get('player1')
        session['player2'] = request.form.get('player2')
        session['game_started'] = True
        session['start_time'] = time.time()
        return redirect(url_for('index'))
    return render_template('start_game.html')


@app.route('/end_game', methods=['POST'])
def end_game():
    # Make sure you are using the same units for both start and end times
    end_time = time.time()  # current time in seconds
    start_time = session.get('start_time', end_time)  # get the start time from the session
    elapsed_time = int(end_time - start_time)  # calculate elapsed time in seconds

    # Store game recap data in the session
    session['game_data'] = {
        'player1': session.get('player1', 'Unknown Player 1'),
        'player2': session.get('player2', 'Unknown Player 2'),
        'elapsed_time': elapsed_time  # store the elapsed time in seconds
    }

    # Reset player names and game state
    session.pop('player1', None)
    session.pop('player2', None)
    session['game_started'] = False  # mark the game as ended

    return jsonify({'success': True}), 200


@app.route('/game_recap')
def game_recap():
    if 'game_data' in session:
        # Pass the game data to the template if it exists
        return render_template('game_recap.html', game_data=session['game_data'])
    else:
        # Redirect to the home page or show an error if there is no game data
        flash('No game to recap.', 'error')
        return redirect(url_for('index'))

@app.route('/get_active_game')
def get_active_game():
    ref = db.reference('game_data/active_game')
    active_game = ref.get()
    return jsonify({'active_game': active_game})

# @app.route('/get_p1')
# def get_p1():
#     p1 = db.reference('game_data/p1')
#     return jsonify({'p1': p1})
#
# @app.route('/get_p2')
# def get_p2():
#     p2 = db.reference('game_data/p2')
#     return jsonify({'p2': p2})

@app.route('/get_speed')
def get_speed():
    speed = db.reference('game_data/speed')
    return jsonify({'speed': speed})

if __name__ == '__main__':
    app.run(debug=True)
