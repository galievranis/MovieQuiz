//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Ranis Galiev on 11.12.2025.
//

import UIKit

class AlertPresenter {
    func show(in viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
            
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
