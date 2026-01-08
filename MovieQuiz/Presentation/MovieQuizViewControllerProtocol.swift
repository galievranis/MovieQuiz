//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ranis Galiev on 08.01.2026.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func toggleButtonsState(isEnabled: Bool)
    func removeImageBorder()
}
