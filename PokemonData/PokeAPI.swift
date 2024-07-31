//
//  PokeAPI.swift
//  Pokedex
//
//  Created by Ahmet Karsli on 30.07.24.
//

import Foundation

struct Pokemon: Codable {
    var results: [PokemonEntry]
}

struct PokemonEntry: Codable {
    var name: String
    var url: String
}

struct PokemonInfo: Codable {
    var name: String
    var sprites: Sprites
    var stats: [PokemonStats]
    var types: [PokemonType]
    var cries: Cries
}

struct Sprites: Codable {
    var other: OtherSprites

    struct OtherSprites: Codable {
        var officialArtwork: OfficialArtwork
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }
}



struct OfficialArtwork: Codable {
    var front_default: String
}

struct PokemonStats: Codable {
    var base_stat: Int
    var stat: StatName
    
    struct StatName: Codable {
        var name: String
    }
}

struct PokemonType: Codable {
    var type: TypeDetail
    
    struct TypeDetail: Codable {
        var name: String
    }
}

struct Cries: Codable {
    var latest: String
}

class PokeAPI: ObservableObject {
    
    // Fetches product information using the given barcode
    func getPokemonList() async throws -> [PokemonEntry] {
        // Construct the API URL
        let baseUrl = "https://pokeapi.co/api/v2/pokemon?limit=494" // to show the national dex of sinnoh (4th gen)
        
        // Ensure the URL is valid
        guard let url = URL(string: baseUrl) else {
            throw FError.invalidURL
        }
        
        // Perform network request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Print raw data for debugging
        /*
        if let rawJson = String(data: data, encoding: .utf8) {
            print("Raw JSON Response: \(rawJson)")
        }
         */
        
        // Check for successful HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FError.invalidResponse
        }
        
        // Decode JSON data into FoodInfo object
        do {
            let decoder = JSONDecoder()
            let PokemonData = try decoder.decode(Pokemon.self, from: data)
            return PokemonData.results
        } catch {
            print("PokemonList Decoding Error: \(error)")
            throw FError.invalidData
        }
    }
    
    func getPokemonInfo(url: String) async throws -> PokemonInfo {

        // Ensure the URL is valid
        guard let url = URL(string: url) else {
            throw FError.invalidURL
        }
        
        // Perform network request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        /*
        // Print raw data for debugging
        if let rawJson = String(data: data, encoding: .utf8) {
            print("Raw JSON Response: \(rawJson)")
        }
         */
        
        // Check for successful HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FError.invalidResponse
        }
        
        // Decode JSON data into FoodInfo object
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PokemonInfo.self, from: data)
        } catch {
            print("PokemonInfo Decoding Error: \(error)")
            throw FError.invalidData
        }
    }
    
    // Enumeration for API-related errors
    enum FError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
}


