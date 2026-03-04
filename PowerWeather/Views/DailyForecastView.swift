import UIKit
import Kingfisher

class DailyForecastView: UIView {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Прогноз на 3 дня"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        
        addSubview(titleLabel)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with data: [WeatherModels.DisplayedDailyWeather]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for day in data {
            let dayView = createDayView(for: day)
            stackView.addArrangedSubview(dayView)
        }
    }
    
    private func createDayView(for data: WeatherModels.DisplayedDailyWeather) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let dayLabel = UILabel()
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dayLabel.text = data.day.capitalized
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        if let iconURL = data.iconURL {
            iconImageView.kf.setImage(with: iconURL)
        }
        
        let maxTempLabel = UILabel()
        maxTempLabel.translatesAutoresizingMaskIntoConstraints = false
        maxTempLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        maxTempLabel.text = data.maxTemp
        maxTempLabel.textColor = .label
        maxTempLabel.textAlignment = .right
        
        let minTempLabel = UILabel()
        minTempLabel.translatesAutoresizingMaskIntoConstraints = false
        minTempLabel.font = .systemFont(ofSize: 16, weight: .regular)
        minTempLabel.text = data.minTemp
        minTempLabel.textColor = .secondaryLabel
        minTempLabel.textAlignment = .right
        
        let tempStack = UIStackView(arrangedSubviews: [maxTempLabel, minTempLabel])
        tempStack.translatesAutoresizingMaskIntoConstraints = false
        tempStack.axis = .horizontal
        tempStack.spacing = 8
        tempStack.alignment = .center
        
        view.addSubview(dayLabel)
        view.addSubview(iconImageView)
        view.addSubview(tempStack)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            iconImageView.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            tempStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tempStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            view.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return view
    }
}
