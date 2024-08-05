//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Ahmet Karsli on 31.07.24.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var pokeAPI = PokeAPI()
    @State private var pokemonInfo: PokemonInfo?
    @State private var errorMessage: String = ""
    
    
    var pokemonName: String
    var pokemonURL: String
    var typeColor: Color
    
    var body: some View {
        NavigationView {
            VStack {
                if let info = pokemonInfo {
                    if let imageURL = URL(string: info.sprites.other.officialArtwork.front_default) {
                        AsyncImage(url: imageURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            } else if phase.error != nil {
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                            } else {
                                ProgressView()
                            }
                        }
                        List {
                            ForEach(info.stats, id: \.stat.name) { stat in
                                HStack {
                                    Text("\(stat.stat.name.capitalized)")
                                        .frame(width: .infinity, alignment: .leading)
                                    Spacer()
                                    Text("\(stat.base_stat)")
                                        .frame(width: .infinity, alignment: .trailing)
                                }
                                .bold()
                                
                            }
                            .listRowBackground(typeColor)
                        }
                        .scrollContentBackground(.hidden)
                        Section(header: Text("Type")) {
                            HStack {
                                ForEach(info.types, id: \.type.name) { type in
                                    Text(type.type.name.capitalized)
                                        .bold()
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                        .onAppear {
                            Task {
                                await fetchPokemonInfo()
                            }
                        }
                }
                
            }
            .background(typeColor)
            .navigationTitle(pokemonName.capitalized)
            .foregroundStyle(.white)

            
        }
    }
    func fetchPokemonInfo() async {
          do {
              pokemonInfo = try await pokeAPI.getPokemonInfo(url: pokemonURL)
          } catch {
              errorMessage = "Failed to fetch Pokémon info: \(error)"
          }
      }
    
}

#Preview {
    PokemonDetailView(
        pokemonName: "Bulbasaur",
        pokemonURL: "https://pokeapi.co/api/v2/pokemon/1/",
        typeColor: .green
    )
}
