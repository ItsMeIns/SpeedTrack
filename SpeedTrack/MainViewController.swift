//
//  ViewController.swift
//  SpeedTrack
//
//  Created by macbook on 20.09.2023.
//

import UIKit
import CoreMotion

class MainViewController: UIViewController {
    
    //MARK: - properties -
    let mainView = MainView()
    var isActive = false
    var timer: Timer?
    var startTime: Date?
    var data: CMPedometerData?
    let averageStepLength = 0.76
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
   
    //MARK: - life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - intents -
    func setupUI() {
        let backgroundView = UIView(frame: view.bounds)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundView.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.green.cgColor]
        backgroundView.layer.addSublayer(gradientLayer)
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        
        view.addSubview(mainView.labelBackground)
        mainView.labelBackground.addSubview(mainView.timeLabel)
        mainView.labelBackground.addSubview(mainView.stepsLabel)
        mainView.labelBackground.addSubview(mainView.distanceLabel)
        mainView.labelBackground.addSubview(mainView.speedLabel)
        view.addSubview(mainView.startStopButton)
        
        mainView.startStopButton.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            mainView.labelBackground.widthAnchor.constraint(equalToConstant: 300),
            mainView.labelBackground.heightAnchor.constraint(equalToConstant: 300),
            mainView.labelBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainView.labelBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            mainView.timeLabel.centerXAnchor.constraint(equalTo: mainView.labelBackground.centerXAnchor),
            mainView.timeLabel.topAnchor.constraint(equalTo: mainView.labelBackground.topAnchor, constant: 45),
            
            mainView.stepsLabel.centerXAnchor.constraint(equalTo: mainView.labelBackground.centerXAnchor),
            mainView.stepsLabel.topAnchor.constraint(equalTo: mainView.timeLabel.bottomAnchor, constant: 25),
            
            mainView.distanceLabel.centerXAnchor.constraint(equalTo: mainView.labelBackground.centerXAnchor),
            mainView.distanceLabel.topAnchor.constraint(equalTo: mainView.stepsLabel.bottomAnchor, constant: 25),
            
            mainView.speedLabel.centerXAnchor.constraint(equalTo: mainView.labelBackground.centerXAnchor),
            mainView.speedLabel.topAnchor.constraint(equalTo: mainView.distanceLabel.bottomAnchor, constant: 25),
            mainView.speedLabel.bottomAnchor.constraint(equalTo: mainView.labelBackground.bottomAnchor, constant: -45),
            
            mainView.startStopButton.widthAnchor.constraint(equalToConstant: 150),
            mainView.startStopButton.heightAnchor.constraint(equalToConstant: 50),
            mainView.startStopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainView.startStopButton.topAnchor.constraint(equalTo: mainView.labelBackground.bottomAnchor, constant: 24),
        ])
        
        mainView.timeLabel.text = "Time - "
        mainView.stepsLabel.text = "Steps - "
        mainView.distanceLabel.text = "Distance - "
        mainView.speedLabel.text = "Speed - "
    }
    
    @objc func startStopButtonTapped() {
        isActive.toggle()
        
        
        if isActive {
            mainView.startStopButton.setTitle("STOP", for: .normal)
            startTime = Date()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
            
            if CMMotionActivityManager.isActivityAvailable() {
                self.activityManager.startActivityUpdates(to: OperationQueue.main) { (data) in
                    DispatchQueue.main.async {
                        if let activity = data {
                            if activity.running == true {
                                print("Running")
                            } else if activity.walking == true {
                                print("Walking")
                            } else if activity.automotive == true {
                                print("Automotive")
                            }
                        }
                    }
                }
            }
            
            if CMPedometer.isStepCountingAvailable() {
                self.pedometer.startUpdates(from: Date()) { (pedometerData, error) in
                    if error == nil {
                        if let response = pedometerData {
                            self.data = response
                            let numberOfSteps = response.numberOfSteps.doubleValue
                            let distanceInMeters = numberOfSteps * self.averageStepLength
                            
                            
                            
                            DispatchQueue.main.async {
                                self.mainView.stepsLabel.text = "Steps - \(response.numberOfSteps)"
                                self.mainView.distanceLabel.text = String(format: "Distance - %.2f м", distanceInMeters)
                            }
                        }
                    }
                }
            }
            
        } else {
            mainView.startStopButton.setTitle("START", for: .normal)
            timer?.invalidate()
            timer = nil
            startTime = nil
        }
    }
    
    @objc func updateTimeLabel() {
        if let startTime = startTime {
            let timeElapsed = Date().timeIntervalSince(startTime)
            let minutes = Int(timeElapsed) / 60
            let seconds = Int(timeElapsed) % 60
            mainView.timeLabel.text = String(format: "Time - %02d:%02d", minutes, seconds)
            
            if let response = data {
                let numberOfSteps = response.numberOfSteps.doubleValue
                let distanceInMeters = numberOfSteps * averageStepLength
                let speedInMetersPerSecond = distanceInMeters / timeElapsed
                
                DispatchQueue.main.async {
                    self.mainView.speedLabel.text = String(format: "Speed - %.2f м/с", speedInMetersPerSecond)
                }
            }
        }
    }
}

