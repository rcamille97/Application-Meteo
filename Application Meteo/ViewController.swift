//
//  ViewController.swift
//  Application Meteo
//
//  Created by Camille on 13/05/2019.
//  Copyright © 2019 ChrisLeCrack&Camille. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    var url = "https://api.openweathermap.org/data/2.5/weather?q=Ajaccio&units=metric&appid=b8c0162f208b810fd4c2e82e370a98a4"
    
    var myCity = "", myWeather = "", myHourOfTheDay : String = ""
    var myTemp : Any? = nil

    var locationManager: CLLocationManager  = CLLocationManager()
    
    var weather : UIImageView = UIImageView()
    var refresh : UIImageView = UIImageView()
    var buttonRefresh : UIButton = UIButton(type: UIButton.ButtonType.custom)
    var city : UILabel = UILabel()
    var temperature : UILabel = UILabel()
    var hourOfTheDay : UILabel = UILabel()
    
    
    override func viewDidLoad() {
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        super.viewDidLoad()
        
        //Shake gesture recognition
        self.becomeFirstResponder()
        
        
        //Place all the elements on the view
        self.setInterface()


    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.setData()
        }
    }
    
    
    
    func getDataFromJSON() -> [String:Any]{
        let data:NSData = try! NSData(contentsOf: URL(string: self.url)!)
        var  myJSONParsed : [String:Any] = [:]
        do {
            myJSONParsed = try JSONSerialization.jsonObject(with: data
                as Data, options: .allowFragments) as! [String:Any]
        } catch let error as NSError {
            print(error)
        }
        
        return myJSONParsed
    }
    
    func setData(){
        let myData = self.getDataFromJSON()
        
        self.myCity = myData["name"] as! String
        self.city.text = self.myCity

        let mainData = myData["main"] as! [String:Any]
        self.myTemp = mainData["temp"]!
        self.temperature.text = "\(self.myTemp ?? "") °"
        
        let mainWeather = myData["weather"] as! [[String:Any]]
        self.myWeather = mainWeather[0]["main"] as! String
        print(myWeather)
        self.weather.image = UIImage(named: self.myWeather)
        
        self.myHourOfTheDay = "\(Calendar.current.component(.hour, from: Date())) : \(Calendar.current.component(.minute , from: Date()))"
        self.hourOfTheDay.text = self.myHourOfTheDay
        
        self.view.backgroundColor = getBackgroundColor()
    }
    
    
    func setUrl(_ location: CLLocationCoordinate2D){
        self.url = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=b8c0162f208b810fd4c2e82e370a98a4"
    }
    
    //Pour gérer la localisation
    func locationManager(_ manager:CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.setUrl(location)
        
        print("user latitude = \(location.latitude)")
        print("user longitude = \(location.longitude)")
        
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    //Permet d'obtenir une couleur de fond en fonction de l'heure
    func getBackgroundColor() -> UIColor {
        let hourOfTheDay = Calendar.current.component(.hour, from: Date())
        print(hourOfTheDay)
        if hourOfTheDay>=23 && hourOfTheDay<=5{
            return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0) //gray
        }else{
            if hourOfTheDay>5 && hourOfTheDay<9{
                return UIColor(red: 102/255, green: 153/255, blue: 255/255, alpha: 1.0) //blue
            }else{
                if hourOfTheDay>=9 && hourOfTheDay<=15{
                    return UIColor(red: 0/255, green: 204/255, blue: 102/255, alpha: 1.0) //green
                }else{
                    if hourOfTheDay>15 && hourOfTheDay<=19{
                        return UIColor(red: 230/255, green: 230/255, blue: 0/255, alpha: 1.0) //yellow
                    }else{
                        if hourOfTheDay>19 && hourOfTheDay<23{
                            return UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0) //orange
                        }else{
                            return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onClickRefresh(_ sender: Any) {
        self.setData()
        print("On refresh tout ça!")
    }
    
    func setInterface(){
        self.setData()
        
        //the weather
        self.weather.contentMode = .scaleAspectFit
        
        //refresh button
        let refreshImage = UIImage(named: "Refresh")
        self.buttonRefresh.setImage(refreshImage, for: [])
        self.buttonRefresh.addTarget(self, action:#selector(self.onClickRefresh(_:)), for: .touchUpInside)
        self.buttonRefresh.imageView?.contentMode = .scaleAspectFit
        
        //city label
        self.city.textAlignment = .center
        self.city.textColor = .white
        self.city.font = city.font.withSize(50)
        self.city.font = UIFont.boldSystemFont(ofSize: 50)
        
        //temperature label
        self.temperature.textAlignment = .center
        self.temperature.textColor = .white
        self.temperature.font = temperature.font.withSize(50)
        self.temperature.font = UIFont.boldSystemFont(ofSize: 50)
        
        //hour label
        self.hourOfTheDay.textAlignment = .center
        self.hourOfTheDay.textColor = .white
        self.hourOfTheDay.font = self.hourOfTheDay.font.withSize(20)
        self.hourOfTheDay.font = UIFont.boldSystemFont(ofSize: 20)
        
        
        self.weather.translatesAutoresizingMaskIntoConstraints = false
        self.buttonRefresh.translatesAutoresizingMaskIntoConstraints = false
        self.city.translatesAutoresizingMaskIntoConstraints = false
        self.temperature.translatesAutoresizingMaskIntoConstraints = false
        self.hourOfTheDay.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.weather)
        self.view.addSubview(self.buttonRefresh)
        self.view.addSubview(self.city)
        self.view.addSubview(self.temperature)
        self.view.addSubview(self.hourOfTheDay)
        
        let views = [ "weather" : self.weather, "refresh" : self.buttonRefresh, "city": self.city, "temperature" : self.temperature, "heure" : self.hourOfTheDay ]
        
        let padding = 10
        let metrics = [ "padding" : padding ]
        
        var constraints = [NSLayoutConstraint]()
        
        let l1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[city]-|",
                                                options: [],
                                                metrics: metrics,
                                                views: views)
        
        constraints += l1
        
        let l2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[weather]-100-|",
                                                options: [],
                                                metrics: metrics,
                                                views: views)
        
        
        constraints += l2
        
        let l3 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[temperature]-|",
                                                options: [],
                                                metrics: metrics,
                                                views: views)
        constraints += l3
        
        let l4 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[heure]-|",
                                                options: [],
                                                metrics: metrics,
                                                views: views)
        constraints += l4
        
        let l5 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-187-[refresh(==30)]-187-|",
                                                options: [],
                                                metrics: metrics,
                                                views: views)
        constraints += l5
        
        
        let c1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[city]-[weather]-[temperature]-[heure]-50-[refresh(==30)]-|",
                                                options: [],
                                                metrics: metrics,
                                                views: views)
        
        constraints += c1
        
        //Ajout de toutes les contraintes
        NSLayoutConstraint.activate(constraints)
    }
    
    
    
    


}

