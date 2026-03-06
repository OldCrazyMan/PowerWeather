import UIKit
import Kingfisher

class CurrentWeatherView: UIView {
    
    // MARK: - UI Elements
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 72, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let conditionIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemYellow
        return imageView
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private let feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let windLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(locationLabel)
        addSubview(temperatureLabel)
        addSubview(conditionIcon)
        addSubview(conditionLabel)
        
        detailsStack.addArrangedSubview(feelsLikeLabel)
        detailsStack.addArrangedSubview(windLabel)
        detailsStack.addArrangedSubview(humidityLabel)
        addSubview(detailsStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            temperatureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            temperatureLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            conditionIcon.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor),
            conditionIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            conditionIcon.widthAnchor.constraint(equalToConstant: 60),
            conditionIcon.heightAnchor.constraint(equalToConstant: 60),
            
            conditionLabel.topAnchor.constraint(equalTo: conditionIcon.bottomAnchor, constant: 4),
            conditionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            conditionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            conditionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            detailsStack.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 20),
            detailsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            detailsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        feelsLikeLabel.widthAnchor.constraint(equalTo: windLabel.widthAnchor).isActive = true
        windLabel.widthAnchor.constraint(equalTo: humidityLabel.widthAnchor).isActive = true
    }
    
    // MARK: - Configuration
    func configure(with weather: WeatherModels.DisplayedCurrentWeather) {
        locationLabel.text = weather.location
        temperatureLabel.text = weather.temperature
        conditionLabel.text = weather.condition
        
        feelsLikeLabel.text = weather.feelsLike
        windLabel.text = weather.windSpeed
        humidityLabel.text = weather.humidity
        
        if let iconURL = weather.iconURL {
            conditionIcon.kf.setImage(with: iconURL)
        }
    }
}
