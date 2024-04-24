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
    var activeGame = false
    var time_start = Date().timeIntervalSince1970
    var p1_name = ""
    var p2_name = ""
    @Published var p1_score = 0
    @Published var p2_score = 0
    @Published var speed = 0
    @Published var puck_in_frame = false
    
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
        
    func startGame(p1_name: String, p2_name: String) {
        self.p1_name = p1_name
        self.p2_name = p2_name
        activeGame = true
    }
    
    func endGame() {
        let game = Game(p1_name: p1_name,
                        p1_score: p1_score,
                        p2_name: p2_name,
                        p2_score: p2_score,
                        time_elapsed: Int(Date().timeIntervalSince1970 - time_start),
                        date: Date().ISO8601Format()
        )
        
        fs.collection("history").addDocument(data: game.dictionary)
        activeGame = false
    }
    
    init() {
        observeScores()
        observeSpeed()
        observePuckInFrame()
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
            if let speed = snapshot.value as? Int {
                self.speed = speed
            }
        }
    }
    
    private func observePuckInFrame() {
        ref.child("/game_data/in_frame").observe(.value) { snapshot in
            if let puckInFrame = snapshot.value as? Bool {
                self.puck_in_frame = puckInFrame
            }
        }
    }
}
