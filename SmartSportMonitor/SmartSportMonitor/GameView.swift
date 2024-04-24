//
//  GameView.swift
//  SmartSportMonitor
//
//  Created by Trey Eckenrod on 4/23/24.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gc: GameController
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text(gc.activeGame ? "Game in Progress" : "Game Over")
                .font(.title)
                .foregroundColor(gc.activeGame ? .green : .red)
            
            HStack(spacing: 40) {
                VStack {
                    Text(gc.p1_name)
                        .font(.title)
                    Text("\(gc.p1_score)")
                        .font(.custom("SCOREBOARD", size: 120))
                        .foregroundColor(.blue)
                }
                
                VStack {
                    Text(gc.p2_name)
                        .font(.title)
                    Text("\(gc.p2_score)")
                        .font(.custom("SCOREBOARD", size: 120))
                        .foregroundColor(.red)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Speed:")
                        .font(.headline)
                    Text("\(gc.speed)")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Puck in Frame:")
                        .font(.headline)
                    Text("\(gc.puck_in_frame ? "Yes" : "No")")
                }
                Spacer()
            }
            
            Button(action: {
                gc.endGame()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("End Game")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    GameView(gc: GameController())
}
