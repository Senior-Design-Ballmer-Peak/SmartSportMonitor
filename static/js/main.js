document.addEventListener('DOMContentLoaded', function() {
    // Assuming there is a <div id='start-time'>UNIX_TIMESTAMP</div> in your HTML
    var startTime = parseInt(document.getElementById('start-time').textContent, 10);
    var timerDisplay = document.getElementById('time-elapsed');

    if (!isNaN(startTime) && startTime > 0) {
        startTimer(startTime);
    }

    function startTimer(startTime) {
        var startTimestamp = startTime * 1000; // Ensure this is in milliseconds
        var timerInterval = setInterval(function () {
            var elapsedMilliseconds = Date.now() - startTimestamp;
            timerDisplay.textContent = formatTime(elapsedMilliseconds);
        }, 1000);
    }

    function formatTime(milliseconds) {
        var totalSeconds = Math.floor(milliseconds / 1000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0');
    }

    // Rest of your existing code for endGame and form submission validation...

});

// Firebase Realtime Database listening for score updates
const firebaseConfig = {
  apiKey: "AIzaSyD28wdQ6XQNcJ2eLln5NmzHQZhHiHo76Y8",
  authDomain: "ssm-csu.firebaseapp.com",
  databaseURL: "https://ssm-csu-default-rtdb.firebaseio.com",
  projectId: "ssm-csu",
  storageBucket: "ssm-csu.appspot.com",
  messagingSenderId: "253492640998",
  appId: "1:253492640998:web:cdda42aa0e9630e9ab4f27"
};

  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);

  // Reference to your database
  const database = firebase.database();

  // Listen for changes in game data
  database.ref('game_data').on('value', (snapshot) => {
    const data = snapshot.val();
    // Update your score display
    if (data) {
      document.getElementById('player1-score').textContent = data.p1 || 0;
      document.getElementById('player2-score').textContent = data.p2 || 0;
      // ... any other fields you want to update in real-time
    }
});