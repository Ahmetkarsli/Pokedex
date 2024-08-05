//
//  PokedexStartView.swift
//  Pokedex
//
//  Created by Ahmet Karsli on 30.07.24.
//

import SwiftUI

struct PokedexStartView: View {
    var body: some View {
        TabView {
            Tab("Pokedex", systemImage: "list.bullet") {
                PokemonListView()
            }
        }
    }
}

#Preview {
    PokedexStartView()
}
