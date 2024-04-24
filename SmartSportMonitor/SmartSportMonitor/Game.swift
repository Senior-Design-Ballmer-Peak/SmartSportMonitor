//
//  Game.swift
//  SmartSportMonitor
//
//  Created by Trey Eckenrod on 4/23/24.
//

import Foundation
import Firebase

struct Game: Identifiable {
    var id = UUID()
    
    var p1_name: String
    var p1_score: Int
    var p2_name: String
    var p2_score: Int
    var time_elapsed: Int
    var date: String
    
    var dictionary: [String: Any] {
        return [
          "p1_score": p1_score,
          "p1_name": p1_name,
          "p2_score": p2_score,
          "p2_name": p2_name,
          "time_elapsed": time_elapsed,
          "date": date,
        ]
    }
}
