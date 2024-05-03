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
    @State private var showAlertP1 = false
    @State private var showAlertP2 = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(gc.activeGame ? "Game in Progress" : "Game Over")
                .font(.title)
                .foregroundColor(gc.activeGame ? .green : .red)
            
            if !gc.activeGame && gc.p1_score > gc.p2_score {
                Text("\(gc.p1_name) Wins!")
                    .font(.title)
            } else if !gc.activeGame && gc.p2_score > gc.p1_score {
                Text("\(gc.p2_name) Wins!")
                    .font(.title)
            } else if !gc.activeGame {
                Text("\(gc.p1_name) and \(gc.p2_name) Tie!")
                    .font(.title)
            }
            
            
            HStack(spacing: 40) {
                VStack {
                    Text(gc.p1_name)
                        .font(.title)
                    Text("\(gc.p1_score)")
                        .font(.custom("SCOREBOARD", size: 120))
                        .foregroundColor(.blue)
                    
                    HStack {
                        Button {
                            gc.addScoreToP1()
                        } label: {
                            Image(systemName: "plus.square.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button {
                            gc.addScoreToP1(true)
                        } label: {
                            Image(systemName: "minus.square.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                VStack {
                    Text(gc.p2_name)
                        .font(.title)
                    Text("\(gc.p2_score)")
                        .font(.custom("SCOREBOARD", size: 120))
                        .foregroundColor(.red)
                    
                    HStack {
                        Button {
                            gc.addScoreToP2()
                        } label: {
                            Image(systemName: "plus.square.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button {
                            gc.addScoreToP2(true)
                        } label: {
                            Image(systemName: "minus.square.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Speed:")
                        .font(.headline)
                    Text(String(format: "%.2f  cm/s", gc.speed))
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Angle:")
                        .font(.headline)
                    Text(String(format: "%.2f\u{00B0}", gc.goalAngle))
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Time Elapsed:")
                        .font(.headline)
                    Text("\(Int(Date().timeIntervalSince1970 - gc.time_start)) seconds")
                        .font(.subheadline)
                }
                Spacer()
            }
            
            
            if gc.activeGame {
                Button(action: {
                    gc.endGame()
                }) {
                    Text("End Game")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            } else {
                Button {
                    gc.resetScore()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Home")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onReceive(gc.$p1_score) { score in
            showAlertP1 = true
            dismissAlertAfterDelay(alert: $showAlertP1)
        }
        .onReceive(gc.$p2_score) { score in
            showAlertP2 = true
            dismissAlertAfterDelay(alert: $showAlertP2)
        }
        .alert(isPresented: $showAlertP1) {
            Alert(
                title: Text("\(gc.p1_name) Scored!"),
                message: Text("Ignore if this is correct. \n Speed of Goal: \(gc.speed) cm/s \n Angle of Goal: \(gc.goalAngle)  /u00B0"),
                dismissButton: .default(Text("Remove Score"), action: {
                    self.gc.addScoreToP1(true)
                })
            )
        }
        .alert(isPresented: $showAlertP2) {
            Alert(
                title: Text("\(gc.p2_name) Scored!"),
                message: Text("Ignore if this is correct. \n Speed of Goal: \(gc.speed) cm/s \n Angle of Goal: \(gc.goalAngle)  /u00B0"),
                dismissButton: .default(Text("Remove Score"), action: {
                    self.gc.addScoreToP2(true)
                })
            )
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func dismissAlertAfterDelay(alert: Binding<Bool>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                alert.wrappedValue = false
            }
        }
    }
}

#Preview {
    GameView(gc: GameController())
}
