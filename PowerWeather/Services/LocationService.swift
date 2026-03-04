import CoreLocation

class LocationService: NSObject, LocationServiceProtocol {
    
    private let manager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocationPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            delegate?.didDenyPermission()
        @unknown default:
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.manager.authorizationStatus == .notDetermined {
                self?.delegate?.didDenyPermission()
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            delegate?.didDenyPermission()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            delegate?.didDenyPermission()
        } else {
            delegate?.didFailWithError(error)
        }
    }
}
