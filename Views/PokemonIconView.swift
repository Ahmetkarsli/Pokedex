//
//  PokemonIconView.swift
//  Pokedex
//
//  Created by Ahmet Karsli on 30.07.24.
//

import SwiftUI

struct PokemonIconView: View {
    let pokemon: PokemonEntry
    let pokemonInfo: PokemonInfo?

    var body: some View {
        VStack {
            if let info = pokemonInfo, let imageURL = URL(string: info.sprites.other.officialArtwork.front_default) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
                Text(pokemon.name)
            }
        }
    }
}

