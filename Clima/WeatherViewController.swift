import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegete {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "cc1b9017f5472189bc144f352e18fa38"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parametrs: [String: String])
    {
        Alamofire.request(url, method: .get, parameters: parametrs).responseJSON
        {
            responds in
            if responds.result.isSuccess
            {
                print("Success! Got the weather data")
                let weatherJSON: JSON = JSON(responds.result.value!)
                self.updateWeatherData(json: weatherJSON)
                print(weatherJSON)
            }
            else
            {
                print("Error \(responds.result.error)")
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON)
    {
        if  let tempResult = json["main"]["temp"].double
        {
        weatherDataModel.tempetature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else
        {
            cityLabel.text = "Weather unavaible"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData()
    {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.tempetature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0
        {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: [String : String] = ["lat": latitude, "lon" : longitude, "appid": APP_ID]
            getWeatherData(url: WEATHER_URL, parametrs: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
        cityLabel.text = "Location Unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    
    func userEnterNewCityName(city: String) {
        let params: [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parametrs: params)
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"
        {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegete = self
        }
    }
    
    
}


