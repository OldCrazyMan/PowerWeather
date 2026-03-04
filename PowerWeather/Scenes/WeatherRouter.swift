import UIKit

@objc protocol WeatherRoutingLogic {}

protocol WeatherDataPassing {
    var dataStore: WeatherDataStore? { get }
}

class WeatherRouter: NSObject, WeatherRoutingLogic, WeatherDataPassing {
    weak var viewController: WeatherViewController?
    var dataStore: WeatherDataStore?
}
