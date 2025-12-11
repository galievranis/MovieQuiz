//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ranis Galiev on 11.12.2025.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: (() -> Void)?
}
