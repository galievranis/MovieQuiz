//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ranis Galiev on 10.12.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
