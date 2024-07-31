//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Ahmet Karsli on 30.07.24.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var pokeAPI = PokeAPI()
    @State private var pokemonList: [PokemonEntry] = []
    @State private var selectedPokemonInfo: [String: PokemonInfo] = [:] // Dictionary to store Pokemon info
    @State private var errorMessage: String = ""
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if pokemonList.isEmpty {
                    ProgressView() // Loading state for the list
                        .onAppear {
                            Task {
                                await fetchPokemonList()
                            }
                        }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(pokemonList, id: \.name) { pokemon in
                                PokemonIconView(pokemon: pokemon, pokemonInfo: selectedPokemonInfo[pokemon.url])
                                    .onAppear {
                                        if selectedPokemonInfo[pokemon.url] == nil {
                                            Task {
                                                await fetchPokemonInfo(url: pokemon.url)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // load PokemonList
    func fetchPokemonList() async {
        do {
            pokemonList = try await pokeAPI.getPokemonList()
        } catch {
            errorMessage = "Failed to fetch Pokemon list: \(error)"
        }
        
    }
    // load information about a specific Pokemon
    func fetchPokemonInfo(url: String) async {
        do {
            let info = try await pokeAPI.getPokemonInfo(url: url)
            DispatchQueue.main.async {
                selectedPokemonInfo[url] = info
            }
            print(selectedPokemonInfo)
        } catch {
            errorMessage = "Failed to fetch Pokemon info: \(error)"
        }
    }
}

#Preview {
    PokemonListView()
}
