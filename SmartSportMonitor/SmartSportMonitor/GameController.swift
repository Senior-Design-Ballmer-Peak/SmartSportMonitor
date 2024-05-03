//
//  GameController.swift
//  SmartSportMonitor
//
//  Created by Trey Eckenrod on 4/23/24.
//

import Foundation
import Firebase
import FirebaseDatabaseInternal

class GameController: ObservableObject {
    let fs = Firestore.firestore()
    var ref = Database.database().reference()
    var winningScore: Int = 99999
    
    @Published var activeGame = false
    var time_start = Date().timeIntervalSince1970
    var p1_name = ""
    var p2_name = ""
    private var timer: Timer?
    
    @Published var p1_score = 0
    @Published var p2_score = 0
    @Published var x = 0
    @Published var y = 0
    @Published var speed = 0.0
    @Published var goalAngle = 0.0
    @Published var puck_in_frame = false
    @Published var timeElapsed: TimeInterval = 0
    
    @Published var lastRally: Int = 0
    @Published var currentRally: Int = 0
    
    private var puckTimer: Timer?
    
    func getHistory(completion: @escaping ([Game]) -> Void) {
        fs.collection("history").order(by: "date").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error loading games: \(error)")
                completion([])
            } else {
                var games: [Game] = []
                for document in querySnapshot!.documents {
                    if let gameData = document.data() as? [String: Any] {
                        if let p1_name = gameData["p1_name"] as? String,
                           let p1_score = gameData["p1_score"] as? Int,
                           let p2_name = gameData["p2_name"] as? String,
                           let p2_score = gameData["p2_score"] as? Int,
                           let time_elapsed = gameData["time_elapsed"] as? Int,
                           let date = gameData["date"] as? String {
                            let game = Game(p1_name: p1_name,
                                            p1_score: p1_score,
                                            p2_name: p2_name,
                                            p2_score: p2_score,
                                            time_elapsed: time_elapsed,
                                            date: date)
                            games.append(game)
                        }
                    }
                }
                completion(games.reversed())
            }
        }
    }
        
    func startGame(p1_name: String, p2_name: String, winningScore: Int) {
        self.p1_name = p1_name
        self.p2_name = p2_name
        if winningScore > 0 {
            self.winningScore = winningScore
        }
        resetScore()
        time_start = Date().timeIntervalSince1970
        startTimer()
        activeGame = true
        
        print("Game Started")
    }
    
    func endGame() {
        let game = Game(p1_name: p1_name,
                        p1_score: p1_score,
                        p2_name: p2_name,
                        p2_score: p2_score,
                        time_elapsed: Int(Date().timeIntervalSince1970 - time_start),
                        date: Date().ISO8601Format()
        )
        
        stopTimer()
        fs.collection("history").addDocument(data: game.dictionary)
        activeGame = false
        
        print("Game Ended")
    }
    
    init() {
        observeScores()
        observeSpeed()
        observePuckInFrame()
        observeAngle()
    }
    
    private func observeScores() {
        ref.child("/game_data/p1").observe(.value) { snapshot in
            if let score = snapshot.value as? Int {
                self.p1_score = score
            }
        }
        
        ref.child("/game_data/p2").observe(.value) { snapshot in
            if let score = snapshot.value as? Int {
                self.p2_score = score
            }
        }
    }
    
    private func observeSpeed() {
        ref.child("/game_data/speed").observe(.value) { snapshot in
            if let speed = snapshot.value as? Double {
                self.speed = speed
            }
        }
    }
    
    private func observePuckInFrame() {
        ref.child("/game_data/in_frame").observe(.value) { snapshot in
            if let puckInFrame = snapshot.value as? Bool {
                self.puck_in_frame = puckInFrame
                if !puckInFrame {
                    self.startPuckTimer()
                } else {
                    self.stopPuckTimer()
                }
            }
        }
    }
    
    private func observeXY() {
        ref.child("/game_data/x").observe(.value) { snapshot in
            if let x_data = snapshot.value as? Int {
                self.x = x_data
            }
        }
        ref.child("/game_data/y").observe(.value) { snapshot in
            if let y_data = snapshot.value as? Int {
                self.y = y_data
            }
        }
    }
    
    private func observeAngle() {
        ref.child("/game_data/angle").observe(.value) { snapshot in
            if let angleData = snapshot.value as? Double {
                self.goalAngle = angleData
            }
        }
    }
    
    private func startPuckTimer() {
        stopPuckTimer()
        
        puckTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            
            if self.y > 1000 {
                self.addScoreToP1()
            } else {
                self.addScoreToP2()
            }
        }
    }
    
    private func stopPuckTimer() {
        puckTimer?.invalidate()
        puckTimer = nil
    }
    
    func addScoreToP1(_ subtract: Bool = false) {
        DispatchQueue.main.async {
            if subtract {
                self.p1_score -= 1
            } else {
                self.p1_score += 1
            }            
            self.ref.child("/game_data/p1").setValue(self.p1_score)
            self.checkScore()
        }
    }
    
    func addScoreToP2(_ subtract: Bool = false) {
        DispatchQueue.main.async {
            if subtract {
                self.p2_score -= 1
            } else {
                self.p2_score += 1
            }
            self.ref.child("/game_data/p2").setValue(self.p2_score)
            self.checkScore()
        }
    }
    
    func resetScore() {
        DispatchQueue.main.async {
            self.p2_score = 0
            self.p2_score = 0
            self.speed = 0
            self.goalAngle = 0
            self.ref.child("/game_data/p1").setValue(self.p1_score)
            self.ref.child("/game_data/p2").setValue(self.p2_score)
            self.ref.child("/game_data/speed").setValue(self.speed)
            self.ref.child("/game_data/angle").setValue(self.speed)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.timeElapsed = Date().timeIntervalSince1970 - self.time_start
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkScore() {
        if p1_score == winningScore {
            endGame()
        }
        if p2_score == winningScore {
            endGame()
        }
    }
}
