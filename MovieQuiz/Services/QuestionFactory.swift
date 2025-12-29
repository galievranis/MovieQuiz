//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ranis Galiev on 08.12.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private enum ComparisonType: CaseIterable {
        case greater
        case less
        
        var text: String {
            switch self {
            case .greater: return "больше"
            case .less: return "меньше"
            }
        }
    }
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let question = self.generateQuestion(rating: rating, imageData: imageData)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func generateQuestion(rating: Float, imageData: Data) -> QuizQuestion {
        guard let comparisonType = ComparisonType.allCases.randomElement() else {
            fatalError("Отсутствуют опции у ComparisonType")
        }
        
        let minThreshold = max(0, rating - 1.0)
        let maxThreshold = min(10, rating + 1.0)
        let threshold = Float.random(in: minThreshold...maxThreshold)
        
        let correctAnswer: Bool
        switch comparisonType {
        case .greater:
            correctAnswer = rating > threshold
        case .less:
            correctAnswer = rating < threshold
        }
        
        let thresholdForUI = Int(threshold.rounded())
        let text: String = "Рейтинг этого фильма \(comparisonType.text), чем \(thresholdForUI)?"
            
        return QuizQuestion(image: imageData,
                            text: text,
                            correctAnswer: correctAnswer)
    }
}
