import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError
    case unknown
}

protocol NetworkServiceProtocol {
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherModels.CurrentWeatherResponse
    func fetchForecast(lat: Double, lon: Double) async throws -> WeatherModels.ForecastResponse
}

class NetworkService: NetworkServiceProtocol {
    
    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let baseURL = "http://api.weatherapi.com/v1"
    
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherModels.CurrentWeatherResponse {
        let endpoint = "\(baseURL)/current.json?key=\(apiKey)&q=\(lat),\(lon)"
        return try await request(endpoint)
    }
    
    func fetchForecast(lat: Double, lon: Double) async throws -> WeatherModels.ForecastResponse {
        let endpoint = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=3"
        return try await request(endpoint)
    }
    
    private func request<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
