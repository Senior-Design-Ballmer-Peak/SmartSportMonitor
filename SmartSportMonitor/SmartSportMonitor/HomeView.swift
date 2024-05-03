//
//  ContentView.swift
//  SmartSportMonitor
//
//  Created by Trey Eckenrod on 4/23/24.
//

import SwiftUI

struct HomeView: View {
    var gc = GameController()
    @State var p1_name = ""
    @State var p2_name = ""
    @State var games: [Game] = []
    @State var winningScore = 0
    @State private var isGameStarted = false
    @State private var isEnteringNames = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.black, lineWidth: 5))
                
                Text("Smart Sport")
                    .font(.custom("SCOREBOARD", size: 60))
                    .fontWeight(.bold)
                    .padding(.top, 20)
                Text("Monitor")
                    .font(.custom("SCOREBOARD", size: 75))
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                Button {
                    isEnteringNames = true
                } label: {
                    Text("Start Game")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .navigationDestination(isPresented: $isGameStarted) {
                    GameView(gc: gc)
                }
                
                Spacer()
                
                Text("Game History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                List {
                    ForEach(games) { game in
                        if game.p1_score > 0 || game.p2_score > 0 {
                            Section(header: Text("\(formatDate(game.date)) - Avg. Rally Time: \(game.time_elapsed / (game.p1_score + game.p2_score)) seconds")) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(game.p1_name)
                                        Spacer()
                                        Text("\(game.p1_score)")
                                    }
                                    HStack {
                                        Text(game.p2_name)
                                        Spacer()
                                        Text("\(game.p2_score)")
                                    }
                                }
                            }
                        } else {
                            Section(header: Text("\(formatDate(game.date)) - \(game.time_elapsed) seconds")) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(game.p1_name)
                                        Spacer()
                                        Text("\(game.p1_score)")
                                    }
                                    HStack {
                                        Text(game.p2_name)
                                        Spacer()
                                        Text("\(game.p2_score)")
                                    }
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    fetchGames()
                }
                .listStyle(GroupedListStyle())
            }
            .sheet(isPresented: $isEnteringNames, content: {
                Text("Enter Player Names")
                    .font(.title)
                
                TextField("Player 1", text: $p1_name)
                    .textContentType(.name)
                    .keyboardType(.alphabet)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(UIColor.secondarySystemBackground))
                    .padding()
                    .cornerRadius(10)

                TextField("Player 2", text: $p2_name)
                    .textContentType(.name)
                    .keyboardType(.alphabet)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color(UIColor.secondarySystemBackground))
                    .padding()
                    .cornerRadius(10)
                
                Text("Winning Score")
                    .font(.title3)
                    .foregroundColor(.secondary)

                
                Text("\(winningScore)")
                    .font(.custom("SCOREBOARD", size: 120))
                    .foregroundColor(.secondary)
                
                HStack {
                    Button {
                        winningScore += 1
                    } label: {
                        Image(systemName: "plus.square.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button {
                        winningScore -= 1
                    } label: {
                        Image(systemName: "minus.square.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                Button {
                    gc.startGame(p1_name: p1_name, p2_name: p2_name, winningScore: winningScore)
                    isGameStarted = true
                    isEnteringNames = false
                } label: {
                    Text("Start")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(p1_name.isEmpty && p2_name.isEmpty)
                
                .cornerRadius(25)
                .padding(.init(top: 30, leading: 0, bottom: 10, trailing: 0))
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.automatic)
            })
        }
        .onAppear {
            fetchGames()
        }
    }
    
    func fetchGames() {
        gc.getHistory { fetchedGames in
            games = fetchedGames
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy - HH:mm"

        if let date = dateFormatterGet.date(from: dateString) {
            return dateFormatterPrint.string(from: date)
        } else {
            return "N/A"
        }
    }
}

#Preview {
    HomeView(games: [Game(p1_name: "Trey", p1_score: 4, p2_name: "Charlie", p2_score: 3, time_elapsed: 14, date: Date().ISO8601Format()), Game(p1_name: "Tristan", p1_score: 8, p2_name: "Miles", p2_score: 9, time_elapsed: 69, date: Date().ISO8601Format())])
}
