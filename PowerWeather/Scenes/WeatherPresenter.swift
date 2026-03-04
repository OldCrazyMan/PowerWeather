import Foundation
import UIKit

protocol WeatherPresentationLogic {
    func presentLoading()
    func presentWeather(response: WeatherScene.LoadWeather.Response)
    func presentError(response: WeatherScene.LoadWeather.Response)
}

class WeatherPresenter: WeatherPresentationLogic {
    
    weak var viewController: WeatherDisplayLogic?
    
    func presentLoading() {
        let viewModel = WeatherScene.LoadWeather.ViewModel(
            state: .loading,
            currentWeather: nil,
            hourlyForecast: nil,
            dailyForecast: nil
        )
        viewController?.displayWeather(viewModel: viewModel)
    }
    
    func presentWeather(response: WeatherScene.LoadWeather.Response) {
        guard let currentWeather = response.currentWeather,
              let forecast = response.forecast else {
            presentError(response: response)
            return
        }
        
        let displayedCurrent = makeCurrentWeather(currentWeather, location: forecast.location)
        let displayedHourly = makeHourlyForecast(forecast.forecast.forecastday)
        let displayedDaily = makeDailyForecast(forecast.forecast.forecastday)
        
        let viewModel = WeatherScene.LoadWeather.ViewModel(
            state: .loaded,
            currentWeather: displayedCurrent,
            hourlyForecast: displayedHourly,
            dailyForecast: displayedDaily
        )
        
        viewController?.displayWeather(viewModel: viewModel)
    }
    
    func presentError(response: WeatherScene.LoadWeather.Response) {
        let message: String
        
        if let error = response.error as? NetworkError {
            switch error {
            case .invalidURL:
                message = "Не удалось подключиться к серверу"
            case .noData:
                message = "Не удалось получить данные о погоде"
            case .decodingError:
                message = "Ошибка при обработке данных"
            case .serverError:
                message = "Сервер временно недоступен"
            case .unknown:
                message = "Произошла неизвестная ошибка"
            }
        } else {
            message = response.error?.localizedDescription ?? "Что-то пошло не так"
        }
        
        let viewModel = WeatherScene.LoadWeather.ViewModel(
            state: .error(message),
            currentWeather: nil,
            hourlyForecast: nil,
            dailyForecast: nil
        )
        
        viewController?.displayWeather(viewModel: viewModel)
    }
    
    // MARK: - Formatting
    private func makeCurrentWeather(_ weather: WeatherModels.CurrentWeatherResponse, location: WeatherModels.Location) -> WeatherModels.DisplayedCurrentWeather {
        let iconString = weather.current.condition.icon
        let iconURL = iconString.hasPrefix("//") ? URL(string: "https:\(iconString)") : URL(string: iconString)
        
        return WeatherModels.DisplayedCurrentWeather(
            location: "\(location.name), \(location.country)",
            temperature: "\(Int(weather.current.tempC))°",
            condition: weather.current.condition.text,
            feelsLike: "Ощущается как \(Int(weather.current.feelslikeC))°",
            windSpeed: "Ветер \(Int(weather.current.windKph)) км/ч",
            humidity: "Влажность \(weather.current.humidity)%",
            iconURL: iconURL
        )
    }
    
    private func makeHourlyForecast(_ forecastDays: [WeatherModels.ForecastDay]) -> [WeatherModels.DisplayedHourlyWeather] {
        var hourly: [WeatherModels.DisplayedHourlyWeather] = []
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for (index, day) in forecastDays.enumerated() {
            for hour in day.hour {
                guard let date = formatter.date(from: hour.time) else { continue }
                let hourValue = calendar.component(.hour, from: date)
                
                let shouldShow: Bool
                if index == 0 {
                    shouldShow = hourValue > currentHour
                } else {
                    shouldShow = index == 1
                }
                
                if shouldShow {
                    let iconURL = URL(string: "https:\(hour.condition.icon)")
                    hourly.append(WeatherModels.DisplayedHourlyWeather(
                        time: String(format: "%02d:00", hourValue),
                        temperature: "\(Int(hour.tempC))°",
                        iconURL: iconURL
                    ))
                }
            }
        }
        
        return hourly
    }
    
    private func makeDailyForecast(_ forecastDays: [WeatherModels.ForecastDay]) -> [WeatherModels.DisplayedDailyWeather] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ru_RU")
        weekdayFormatter.dateFormat = "EEEE"
        
        return forecastDays.map { day in
            let date = dateFormatter.date(from: day.date) ?? Date()
            let dayName = weekdayFormatter.string(from: date).capitalized
            let iconURL = URL(string: "https:\(day.day.condition.icon)")
            
            return WeatherModels.DisplayedDailyWeather(
                day: dayName,
                maxTemp: "\(Int(day.day.maxtempC))°",
                minTemp: "\(Int(day.day.mintempC))°",
                iconURL: iconURL
            )
        }
    }
}
