document.addEventListener('DOMContentLoaded', function () {
    // Update scores
    function updateScores() {
        // Implement AJAX request to get scores from server
    }

    // Update puck speed
    function updatePuckSpeed() {
        // Implement AJAX request to get puck speed from server
    }

    // Setup WebSocket or AJAX long polling to update scores and puck speed
    // ...

    // Call update functions periodically or on events
    updateScores();
    updatePuckSpeed();
});

document.addEventListener('DOMContentLoaded', function () {
    var timerInterval;
    var timerDisplay = document.getElementById('time-elapsed');

    // Make sure the startTimer function is correctly calculating the elapsed time
    function startTimer(startTime) {
        var startTimeSeconds = startTime; // Make sure this is in seconds
        timerInterval = setInterval(function () {
            var currentTime = Math.floor(Date.now() / 1000); // Convert current time to seconds
            var elapsedTime = currentTime - startTimeSeconds;
            timerDisplay.textContent = formatTime(elapsedTime);
        }, 1000);
    }

    // Corrected formatTime function to handle seconds
    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60);
        var remainingSeconds = seconds % 60;
        return minutes.toString().padStart(2, '0') + ":" + remainingSeconds.toString().padStart(2, '0');
    }


    // End game function that sends a POST request to the Flask server
    function endGame() {
        clearInterval(timerInterval); // Stop the timer
        fetch('/end_game', { method: 'POST' })
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    window.location.href = '/game_recap'; // Redirect on success
                }
            })
            .catch(error => console.error('Error:', error));
    }


    // Expose the endGame function to be callable from HTML
    window.endGame = endGame;

    // Start the game timer
    startTimer();
});

document.addEventListener('DOMContentLoaded', function() {
    var startTime = parseInt(document.getElementById('start-time').textContent, 10);
    var timerDisplay = document.getElementById('time-elapsed');

    if (!isNaN(startTime) && startTime > 0) {
        var startTimestamp = startTime * 1000; // Convert to milliseconds
        updateTimer(startTimestamp);
    }

    function updateTimer(startTimestamp) {
        setInterval(function() {
            var now = Date.now();
            var elapsedMilliseconds = now - startTimestamp;
            timerDisplay.textContent = formatTime(elapsedMilliseconds);
        }, 1000);
    }

    function formatTime(milliseconds) {
        var totalSeconds = Math.floor(milliseconds / 1000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0');
    }
});

document.getElementById('start-game-form').addEventListener('submit', function(event) {
    var player1 = document.getElementById('player1').value.trim();
    var player2 = document.getElementById('player2').value.trim();

    if (player1 === '' || player2 === '') {
        alert('Please enter names for both players.');
        event.preventDefault(); // Prevent form from submitting
    }
});

// In your main.js or inline within index.html
function fetchData() {
  // Active game status
  fetch('/get_active_game').then(response => response.json()).then(data => {
    document.getElementById('active-game-value').textContent = data.active_game;
  });

  // Puck in frame status
  fetch('/get_puck_in_frame').then(response => response.json()).then(data => {
    document.getElementById('puck-in-frame-value').textContent = data.puck_in_frame;
  });

  // Radius
  fetch('/game_data/rad').then(response => response.json()).then(data => {
    document.getElementById('rad-value').textContent = data.rad;
  });

  // Puck speed
  fetch('/get_puck_speed').then(response => response.json()).then(data => {
    document.getElementById('puck-speed-value').textContent = data.puck_speed;
  });

  // In frame
  fetch('/game_data/in_frame').then(response => response.json()).then(data => {
    document.getElementById('in-frame-value').textContent = data.in_frame;
  });

  // Speed
  fetch('/game_data/speed').then(response => response.json()).then(data => {
    document.getElementById('speed-value').textContent = data.speed;
  });

  // X position
  fetch('/game_data/x').then(response => response.json()).then(data => {
    document.getElementById('x-value').textContent = data.x;
  });

  // Y position
  fetch('/game_data/y').then(response => response.json()).then(data => {
    document.getElementById('y-value').textContent = data.y;
  });

  // Re-run this function every 5 seconds
  setTimeout(fetchData, 5000);
}

// Start polling when the page loads
document.addEventListener('DOMContentLoaded', fetchData);
