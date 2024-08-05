//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Ahmet Karsli on 30.07.24.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var pokeAPI = PokeAPI()
    @State private var pokemonList = [PokemonEntry]()
    @State private var selectedPokemonInfo: [String: PokemonInfo] = [:] // Dictionary to store Pokemon info
    @State private var errorMessage: String = ""
    @State private var searchedPokemon = ""
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Color for Type of the Pokemon
    let PokemonTypeColor: [String: Color] = [
        "normal": Color(hex: 0xA8A77A),
        "fire": Color(hex: 0xEE8130),
        "water": Color(hex: 0x6390F0),
        "electric": Color(hex: 0xF7D02C),
        "grass": Color(hex: 0x7AC74C),
        "ice": Color(hex: 0x96D9D6),
        "fighting": Color(hex: 0xC22E28),
        "poison": Color(hex: 0xA33EA1),
        "ground": Color(hex: 0xE2BF65),
        "flying": Color(hex: 0xA98FF3),
        "psychic": Color(hex: 0xF95587),
        "bug": Color(hex: 0xA6B91A),
        "rock": Color(hex: 0xB6A136),
        "ghost": Color(hex: 0x735797),
        "dragon": Color(hex: 0x6F35FC),
        "dark": Color(hex: 0x705746),
        "steel": Color(hex: 0xB7B7CE),
        "fairy": Color(hex: 0xD685AD)
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
                            ForEach(filteredPokemon, id: \.name) { entry in
                                let typeColor = PokemonTypeColor[selectedPokemonInfo[entry.url]?.types.first?.type.name ?? ""]
                                VStack {
                                    NavigationLink() {
                                        PokemonDetailView(pokemonName: entry.name, pokemonURL: entry.url, typeColor: typeColor ?? .clear)
                                    } label: {
                                        PokemonIconView(pokemon: entry, pokemonInfo: selectedPokemonInfo[entry.url])
                                            .onAppear {
                                                if selectedPokemonInfo[entry.url] == nil {
                                                    Task {
                                                        await fetchPokemonInfo(url: entry.url)
                                                    }
                                                }
                                            }
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .padding()
                                .foregroundStyle(.white)
                                .bold()
                                .background(typeColor)
                                .clipShape(.rect(cornerRadius: 15))
                            }
                        }
                        
                    }
                }
            }
            .navigationTitle("Pokedex")
            .foregroundStyle(.black)
        }
        .searchable(text: $searchedPokemon)
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
            //print(selectedPokemonInfo)
        } catch {
            errorMessage = "Failed to fetch Pokemon info: \(error)"
        }
    }
    
    private var filteredPokemon: [PokemonEntry] {
        if searchedPokemon.isEmpty {
            return pokemonList
        }
        return pokemonList.filter { $0.name.lowercased().contains(searchedPokemon.lowercased()) }
    }
}

#Preview {
    PokemonListView()
}

