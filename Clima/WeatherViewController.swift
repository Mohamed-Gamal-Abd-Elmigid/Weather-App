//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , CLLocationManagerDelegate , ChangeCityDelegate
{
  
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "0afdc2362c74fdf70cc2855401fd93ea"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManger = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String , parameters : [String:String])
    {
        Alamofire.request(url , method: .get , parameters: parameters).responseJSON
        { (response) in
            if response.result.isSuccess
            {
                print("Succrss , Got the weather Data")
                
                let weatherJSON : JSON = JSON(response.result.value!)

                self.updateWeatherData(json: weatherJSON)
            }
            else
            {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Conection Issues"
            }
        }

    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
        
    func updateWeatherData(json : JSON)
    {
        if let tempResult = json["main"]["temp"].double
        {
        weatherDataModel.temprture = Int(tempResult - 273.15)
        
        weatherDataModel.city = json["name"].stringValue

        weatherDataModel.condition = json["weather"]["id"].intValue
        
        weatherDataModel.weatherIConName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else
        {
            cityLabel.text = "Weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
        
    func updateUIWithWeatherData()
    {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temprture) + "°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIConName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy >  0
        {
            locationManger.stopUpdatingLocation()
            locationManger.delegate = nil
            print("Longitude = \(location.coordinate.longitude) , Latitude =\(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
                
            let params : [String : String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL , parameters : params)
        }
        
    }
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error)
        cityLabel.text = "Location Unavalable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnterdANewCityName(city: String)
      {
        let prams : [String : String] = ["q" : city , "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: prams)
      }
      
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "changeCityName"
        {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
        
    }
    
    
    
}


