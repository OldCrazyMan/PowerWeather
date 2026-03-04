import Foundation
import CoreLocation

protocol WeatherBusinessLogic {
    func loadWeather(request: WeatherScene.LoadWeather.Request)
    func retry(request: WeatherScene.Retry.Request)
}

protocol WeatherDataStore {
    var currentLocation: CLLocation? { get set }
    var currentWeather: WeatherModels.CurrentWeatherResponse? { get }
    var forecast: WeatherModels.ForecastResponse? { get }
}

class WeatherInteractor: WeatherBusinessLogic, WeatherDataStore {
    
    var presenter: WeatherPresentationLogic?
    var locationService: LocationServiceProtocol?
    var networkService: NetworkServiceProtocol?
    
    var currentLocation: CLLocation?
    var currentWeather: WeatherModels.CurrentWeatherResponse?
    var forecast: WeatherModels.ForecastResponse?
    
    private let defaultLatitude = 55.7558 // Москва
    private let defaultLongitude = 37.6173
    private var isLocating = false
    private var hasData = false
    
    func loadWeather(request: WeatherScene.LoadWeather.Request) {
        if hasData { return }
        
        if let lat = request.latitude, let lon = request.longitude {
            fetchWeather(lat: lat, lon: lon)
            return
        }
        
        if let location = currentLocation {
            fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            return
        }
        
        guard !isLocating else {
            presenter?.presentLoading()
            return
        }
        
        presenter?.presentLoading()
        startLocationService()
    }
    
    func retry(request: WeatherScene.Retry.Request) {
        hasData = false
        
        if let location = currentLocation {
            fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        } else {
            startLocationService()
        }
    }
    
    private func startLocationService() {
        isLocating = true
        locationService?.delegate = self
        locationService?.requestLocationPermission()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, self.isLocating, !self.hasData else { return }
            self.isLocating = false
            self.useDefaultLocation()
        }
    }
    
    private func fetchWeather(lat: Double, lon: Double) {
        guard !hasData else { return }
        
        presenter?.presentLoading()
        
        Task { [weak self] in
            guard let self = self,
                  let networkService = self.networkService else { return }
            
            do {
                async let current = networkService.fetchCurrentWeather(lat: lat, lon: lon)
                async let forecast = networkService.fetchForecast(lat: lat, lon: lon)
                
                let (currentWeather, forecastData) = await (try current, try forecast)
                
                self.currentWeather = currentWeather
                self.forecast = forecastData
                self.currentLocation = CLLocation(latitude: lat, longitude: lon)
                self.hasData = true
                self.isLocating = false
                
                let response = WeatherScene.LoadWeather.Response(
                    currentWeather: currentWeather,
                    forecast: forecastData,
                    error: nil
                )
                
                await MainActor.run {
                    self.presenter?.presentWeather(response: response)
                }
                
            } catch {
                let response = WeatherScene.LoadWeather.Response(
                    currentWeather: nil,
                    forecast: nil,
                    error: error
                )
                
                await MainActor.run {
                    self.presenter?.presentError(response: response)
                }
            }
        }
    }
    
    private func useDefaultLocation() {
        guard !hasData else { return }
        fetchWeather(lat: defaultLatitude, lon: defaultLongitude)
    }
}

// MARK: - LocationServiceDelegate
extension WeatherInteractor: LocationServiceDelegate {
    func didUpdateLocation(latitude: Double, longitude: Double) {
        if hasData {
            isLocating = false
            return
        }
        
        isLocating = false
        currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        fetchWeather(lat: latitude, lon: longitude)
    }
    
    func didFailWithError(_ error: Error) {
        isLocating = false
        if !hasData {
            useDefaultLocation()
        }
    }
    
    func didDenyPermission() {
        isLocating = false
        if !hasData {
            useDefaultLocation()
        }
    }
}
