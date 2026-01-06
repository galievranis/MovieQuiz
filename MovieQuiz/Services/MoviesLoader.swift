//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Ranis Galiev on 28.12.2025.
//

import Foundation

struct MoviesLoader: MoviesLoading {
    private enum MoviesLoaderError: LocalizedError {
        case apiError(String)
        case emptyMoviesList
        
        var errorDescription: String? {
            switch self {
            case .apiError(let message):
                return message
            case .emptyMoviesList:
                return "Не удалось загрузить список фильмов."
            }
        }
    }
    
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesURL")
        }
        
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    if !mostPopularMovies.errorMessage.isEmpty {
                        handler(.failure(MoviesLoaderError.apiError(mostPopularMovies.errorMessage)))
                        return
                    }
                    
                    if mostPopularMovies.items.isEmpty {
                        handler(.failure(MoviesLoaderError.emptyMoviesList))
                        return
                    }
                    
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
