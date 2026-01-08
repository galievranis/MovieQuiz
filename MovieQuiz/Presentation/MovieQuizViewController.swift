import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var answerButtons: [UIButton]!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        showLoadingIndicator()
        
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        removeImageBorder()
        toggleButtonsState(isEnabled: true)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            accessibilityIdentifier: "Game result"
        ) { [weak self] in
            self?.presenter.resetQuestionIndex()
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        }
        
        ResultAlertPresenter.show(in: self, with: alert)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        toggleButtonsState(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService?.store(
                correct: correctAnswers,
                total: presenter.getQuestionsAmount()
            )
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultMessage(),
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            
            self.questionFactory?.requestNextQuestion()
            
            removeImageBorder()
        }
    }
    
    private func removeImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    private func toggleButtonsState(isEnabled: Bool) {
        for button in answerButtons {
            button.isEnabled = isEnabled
        }
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService else {
            return "Статистика недоступна"
        }
        
        let bestGame = statisticService.bestGame
        
        return """
            Ваш результат: \(correctAnswers)/\(presenter.getQuestionsAmount())
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            accessibilityIdentifier: "Network error"
        ) { [weak self] in
            self?.presenter.resetQuestionIndex()
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        }
        
        ResultAlertPresenter.show(in: self, with: alert)
    }
}
