import UIKit

protocol WeatherDisplayLogic: AnyObject {
    func displayWeather(viewModel: WeatherScene.LoadWeather.ViewModel)
}

class WeatherViewController: UIViewController {
    
    var interactor: WeatherBusinessLogic?
    var router: (NSObjectProtocol & WeatherRoutingLogic & WeatherDataPassing)?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Попробовать снова", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }()
    
    private let currentWeatherView = CurrentWeatherView()
    private let hourlyForecastView = HourlyForecastView()
    private let dailyForecastView = DailyForecastView()
    
    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let interactor = WeatherInteractor()
        let presenter = WeatherPresenter()
        let router = WeatherRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
        
        interactor.locationService = LocationService()
        interactor.networkService = NetworkService()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadWeather()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Повергода"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
        
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        contentView.addSubview(currentWeatherView)
        contentView.addSubview(hourlyForecastView)
        contentView.addSubview(dailyForecastView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
            
            currentWeatherView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            currentWeatherView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentWeatherView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            hourlyForecastView.topAnchor.constraint(equalTo: currentWeatherView.bottomAnchor, constant: 20),
            hourlyForecastView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hourlyForecastView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dailyForecastView.topAnchor.constraint(equalTo: hourlyForecastView.bottomAnchor, constant: 10),
            dailyForecastView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dailyForecastView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dailyForecastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    private func loadWeather() {
        let request = WeatherScene.LoadWeather.Request(latitude: nil, longitude: nil)
        interactor?.loadWeather(request: request)
    }
    
    @objc private func retryButtonTapped() {
        let request = WeatherScene.Retry.Request()
        interactor?.retry(request: request)
    }
    
    private func updateUI(for state: WeatherModels.LoadingState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .loading:
                self.loadingIndicator.startAnimating()
                self.scrollView.isHidden = true
                self.errorView.isHidden = true
                
            case .loaded:
                self.loadingIndicator.stopAnimating()
                self.scrollView.isHidden = false
                self.errorView.isHidden = true
                
            case .error(let message):
                self.loadingIndicator.stopAnimating()
                self.scrollView.isHidden = true
                self.errorView.isHidden = false
                self.errorLabel.text = message
            }
        }
    }
}

// MARK: - WeatherDisplayLogic
extension WeatherViewController: WeatherDisplayLogic {
    func displayWeather(viewModel: WeatherScene.LoadWeather.ViewModel) {
        updateUI(for: viewModel.state)
        
        guard let currentWeather = viewModel.currentWeather,
              let hourlyForecast = viewModel.hourlyForecast,
              let dailyForecast = viewModel.dailyForecast else {
            return
        }
        
        currentWeatherView.configure(with: currentWeather)
        hourlyForecastView.configure(with: hourlyForecast)
        dailyForecastView.configure(with: dailyForecast)
    }
}
