//
//  GuessPokemonView.swift
//  Pokedex
//
//  Created by Ahmet Karsli on 04.08.24.
//

import SwiftUI

struct GuessPokemonView: View {
    
    @State var randomNumber: Int = Int.random(in: 1...151)
    @StateObject private var pokeAPI = PokeAPI()
    @State private var pokemonInfo: PokemonInfo?
    @State private var errorMessage: String = ""
    @State private var title = "Who is this Pokémon?"
    @State private var guessing = true
    @State private var showAlert = false
    @State private var showInfoAlert = false
    @State var guessPokemon: String = ""
    @State var messageText: String = ""
    
    @State var countRightGuesses: Int = 0
    
    var pokemonName: String = ""
    var pokemonURL = "https://pokeapi.co/api/v2/pokemon/"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.red.opacity(0.9).ignoresSafeArea()
                
                VStack {
                    if let pokemonInfo = pokemonInfo {
                        AsyncImage(url: URL(string: pokemonInfo.sprites.other.officialArtwork.front_default)) { image in
                            image.image?
                                .resizable()
                                .scaledToFit()
                                .colorMultiply(guessing ? Color.black : Color.white)
                        }
                        Text(messageText)
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                        
                        
                        HStack {
                            TextField("Guess the Pokémon", text: $guessPokemon)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding()
                                .autocorrectionDisabled()
                            Button (action: {
                                if (guessPokemon.lowercased() == pokemonInfo.name.lowercased()) {
                                    guessing = false
                                    messageText = "You got it! It's \(pokemonInfo.name.capitalized)"
                                    countRightGuesses += 1

                                } else {
                                    messageText = "You are wrong! Try again."
                                    countRightGuesses = 0
                                    showAlert = true
                                }
                                guessPokemon = ""
                            }, label: {
                                Text("guess")
                                    .padding()
                                    .background(guessing ? Color.blue: Color.gray)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .cornerRadius(10)
                            })
                            .padding()
                        }
                        Button(action: {
                            randomNumber = Int.random(in: 1...151)
                            guessing = true
                            if guessing == false {
                                countRightGuesses = 0

                            }
                            fetchNewPokemon(false)
                        }, label: {
                            Text("Generate new Pokemon for Guess.")
                                .bold()
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        })
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Guess Result"),
                        message: Text("Your Guess is \(countRightGuesses)"),
                        dismissButton: .default(Text("OK"))
                    )
                
                }
                .onAppear {
                    fetchNewPokemon(false)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("\(countRightGuesses)")
                            .padding()
                            .background(.white)
                            .foregroundStyle(.blue)
                            .cornerRadius(10)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "info.circle")
                            .onTapGesture {
                                showInfoAlert = true
                            }
                            .alert(isPresented: $showInfoAlert) {
                                
                                Alert(
                                    title: Text("Game rules:"),
                                    message: Text("With each correct guess, you earn 1 point. If you guess incorrectly, you lose the game. Clicking 'Generate new Pokemon for Guess' after a correct guess does not affect your score, only if you cannot guess.")
                                )
                            }
                    }
                }
                .navigationTitle(title)
                .bold()
            }
        }
    }
    
    
    func fetchPokemonInfo() async {
          do {
              pokemonInfo = try await pokeAPI.getPokemonInfo(url: pokemonURL)
          } catch {
              errorMessage = "Failed to fetch Pokémon info: \(error)"
          }
      }
    
    func fetchRandomPokemon(int: Int) async {
        let RandomPokemonURL = "https://pokeapi.co/api/v2/pokemon/\(int)"
        do {
            pokemonInfo = try await pokeAPI.getPokemonInfo(url: RandomPokemonURL)
        } catch {
            errorMessage = "Failed to fetch Pokemon info: \(error)"
        }
    }
    
    func fetchNewPokemon(_ isDelay: Bool) {
        Task {
            if isDelay == true {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    print("Failed to sleep: \(error)")
                }
            }
            
            await fetchRandomPokemon(int: randomNumber)
        }
    }
}
#Preview {
    GuessPokemonView()
}
