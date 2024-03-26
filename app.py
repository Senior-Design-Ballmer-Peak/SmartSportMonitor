import time

from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Set a secret key for sessions

@app.route('/')
def index():
    # Get player names and game state from the session
    player1 = session.get('player1', 'Player 1')
    player2 = session.get('player2', 'Player 2')
    game_started = session.get('game_started', False)
    return render_template('index.html', player1=player1, player2=player2, game_started=game_started)


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
