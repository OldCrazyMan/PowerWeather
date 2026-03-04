import Foundation

enum WeatherScene {
    
    // MARK: - Use cases
    enum LoadWeather {
        struct Request {
            let latitude: Double?
            let longitude: Double?
        }
        
        struct Response {
            let currentWeather: WeatherModels.CurrentWeatherResponse?
            let forecast: WeatherModels.ForecastResponse?
            let error: Error?
        }
        
        struct ViewModel {
            let state: WeatherModels.LoadingState
            let currentWeather: WeatherModels.DisplayedCurrentWeather?
            let hourlyForecast: [WeatherModels.DisplayedHourlyWeather]?
            let dailyForecast: [WeatherModels.DisplayedDailyWeather]?
        }
    }
    
    enum Retry {
        struct Request {}
    }
}
