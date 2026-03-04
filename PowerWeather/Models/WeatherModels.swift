
import Foundation

enum WeatherModels {
    
    // MARK: - Current Weather
    struct CurrentWeatherResponse: Codable {
        let location: Location
        let current: Current
    }
    
    // MARK: - Forecast Response
    struct ForecastResponse: Codable {
        let location: Location
        let current: Current
        let forecast: Forecast
    }
    
    struct Location: Codable {
        let name: String
        let country: String
        let localtime: String
    }
    
    struct Current: Codable {
        let tempC: Double
        let condition: Condition
        let windKph: Double
        let humidity: Int
        let feelslikeC: Double
        
        enum CodingKeys: String, CodingKey {
            case tempC = "temp_c"
            case condition
            case windKph = "wind_kph"
            case humidity
            case feelslikeC = "feelslike_c"
        }
    }
    
    struct Condition: Codable {
        let text: String
        let icon: String
        let code: Int
    }
    
    struct Forecast: Codable {
        let forecastday: [ForecastDay]
    }
    
    struct ForecastDay: Codable {
        let date: String
        let day: Day
        let hour: [Hour]
    }
    
    struct Day: Codable {
        let maxtempC: Double
        let mintempC: Double
        let condition: Condition
        
        enum CodingKeys: String, CodingKey {
            case maxtempC = "maxtemp_c"
            case mintempC = "mintemp_c"
            case condition
        }
    }
    
    struct Hour: Codable {
        let time: String
        let tempC: Double
        let condition: Condition
        
        enum CodingKeys: String, CodingKey {
            case time
            case tempC = "temp_c"
            case condition
        }
    }
    
    // MARK: - Display Models
    struct DisplayedCurrentWeather {
        let location: String
        let temperature: String
        let condition: String
        let feelsLike: String
        let windSpeed: String
        let humidity: String
        let iconURL: URL?
    }
    
    struct DisplayedHourlyWeather {
        let time: String
        let temperature: String
        let iconURL: URL?
    }
    
    struct DisplayedDailyWeather {
        let day: String
        let maxTemp: String
        let minTemp: String
        let iconURL: URL?
    }
    
    enum LoadingState {
        case loading
        case loaded
        case error(String)
    }
}
