//
//  MovieQuizViewControllerMock.swift
//  MovieQuiz
//
//  Created by Ranis Galiev on 10.01.2026.
//

@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {}
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    
    func showLoadingIndicator() {}
    
    func hideLoadingIndicator() {}
    
    func showNetworkError(message: String) {}
    
    func toggleButtonsState(isEnabled: Bool) {}
    
    func removeImageBorder() {}
}
