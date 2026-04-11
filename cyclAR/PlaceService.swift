//
//  PlaceService.swift
//  cyclAR
//
//  Created by Nandini Swami on 4/11/26.
//

import Foundation

enum PlacesError: Error {
    case invalidURL
    case badResponse
    case parse
}

final class PlacesService {
    static let shared = PlacesService()
    private init() {}

    private let apiKey = "YOUR_API_KEY_HERE"

    func fetchSuggestions(
        input: String,
        sessionToken: String,
        completion: @escaping (Result<[PlaceSuggestion], Error>) -> Void
    ) {
        guard let url = URL(string: "https://places.googleapis.com/v1/places:autocomplete") else {
            completion(.failure(PlacesError.invalidURL))
            return
        }

        let body: [String: Any] = [
            "input": input,
            "sessionToken": sessionToken,
            "includedPrimaryTypes": ["street_address"],
            "languageCode": "en"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(PlacesError.parse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.addValue(
            "suggestions.placePrediction.placeId,suggestions.placePrediction.text.text,suggestions.placePrediction.structuredFormat",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(PlacesError.badResponse))
                return
            }

            do {
                guard
                    let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let suggestions = root["suggestions"] as? [[String: Any]]
                else {
                    completion(.success([]))
                    return
                }

                let mapped: [PlaceSuggestion] = suggestions.compactMap { item in
                    guard
                        let placePrediction = item["placePrediction"] as? [String: Any],
                        let placeId = placePrediction["placeId"] as? String
                    else {
                        return nil
                    }

                    let textObj = placePrediction["text"] as? [String: Any]
                    let fullText = (textObj?["text"] as? String) ?? ""

                    let structured = placePrediction["structuredFormat"] as? [String: Any]
                    let mainTextObj = structured?["mainText"] as? [String: Any]
                    let secondaryTextObj = structured?["secondaryText"] as? [String: Any]

                    let primaryText = (mainTextObj?["text"] as? String) ?? fullText
                    let secondaryText = (secondaryTextObj?["text"] as? String) ?? ""

                    return PlaceSuggestion(
                        id: placeId,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        fullText: fullText
                    )
                }

                completion(.success(mapped))
            } catch {
                completion(.failure(PlacesError.parse))
            }
        }.resume()
    }
}
