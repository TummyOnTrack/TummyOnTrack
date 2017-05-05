//
//  TTHomeTableTableViewController.swift
//  TummyOnTrack
//
//
//  //  <div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a></div>
//  Created by Gauri Tikekar on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import MagicPie
import Firebase
import Charts
import UserNotifications

class TTHomeTableTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ChartViewDelegate {

    @IBOutlet weak var setupGoalButton: UIButton!
    @IBOutlet weak var goalPointsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    var pieLayer : PieLayer! = nil

    var imagePicker: UIImagePickerController!


    @IBOutlet weak var monButton: UIButton!

    @IBOutlet weak var satButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var thursButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var tuesButton: UIButton!
    @IBOutlet weak var sunButton: UIButton!


    @IBOutlet weak var chartsView: BarChartView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // load default food items
        loadFoodItems()

        setToday()
        setTrackingAlarm()

        pieLayer = PieLayer()
        pieLayer.frame = pieView.frame
        pieLayer.minRadius = Float(pieView.frame.width/3)
        pieLayer.maxRadius = Float(pieView.frame.width/2)

        view.layer.addSublayer(pieLayer)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentProfileDetails()

    }

    func setToday() {
        let date = Date()
        let calendar = Calendar.current

        //let year = calendar.component(.year, from: date)
        //let month = calendar.component(.month, from: date)
        //TODO: Bad logic. Fix it.
        let day = calendar.component(.weekday, from: date)
        
    }
    
    func setTrackingAlarm() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .notDetermined)
            {
                print("Push authorized")
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
                { (success, error) in
                    if success {
                        print("Permission Granted")
                        let content = UNMutableNotificationContent()
                        content.title = "What did you eat today?"
                        content.body = "Did you track your meals today?"
                        content.categoryIdentifier = "alarm"
                        content.userInfo = ["customData": "fizzbuzz"]
                        content.sound = UNNotificationSound.default()
                        
                        var dateComponents = DateComponents()
                        dateComponents.hour = 20
                        dateComponents.minute = 5
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24, repeats: true)//UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        center.removeAllDeliveredNotifications()
                        center.removeAllPendingNotificationRequests()
                        center.add(request)
                    } else {
                        print("There was a problem!")
                    }
                }

            }
            
        }
        
    }


    func setButtonColor( aButton: UIButton, aColor: UIColor) {
        aButton.setTitleColor(aColor, for: UIControlState.normal)
    }

    func loadFoodItems() {
        TTFoodItem.getFoodItems(success: { () in
            //self.pieView.reloadInputViews()
        }, failure: { (error: Error) -> ()  in
            print("Failed to load food items")
        })
    }
    @IBAction func onSetupGoalClick(_ sender: Any) {
        let alert = UIAlertController(title: "Change Goal Points",
                                      message: "\n\n",
                                      preferredStyle: .alert)
        
        let slider = UISlider(frame: CGRect(x: 10, y: 60, width: 250, height: 10))
        slider.maximumValue = 100
        slider.minimumValue = 10
        slider.value = Float(TTProfile.currentProfile!.goalPoints)
        alert.view.addSubview(slider)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
            self.goalPointsLabel.text = "Goal: " + "\(Int(slider.value))" + "Pts"
            TTProfile.currentProfile?.setGoalPoints(aGoalPoints: Int(slider.value))
        }))
        present(alert, animated: true, completion: nil)
    }

    func setCurrentProfileDetails() {
        if TTProfile.currentProfile != nil {
            populateProfileInfo()
        }
        TTUser.currentUser?.getProfiles(success: { (aProfiles: [TTProfile]) in
            
        }) { (error: NSError) in
            
        }
    }

    func populateProfileInfo() {
        let currentProfile_ = TTProfile.currentProfile
        self.navigationItem.title = "Hi " + (currentProfile_?.name)! + "!"
        self.profileImageView.setImageWith((currentProfile_?.profileImageURL)!)
        //setupGoalButton.isHidden = true
        var pieColor = UIColor.init(red: 244/255.0, green: 115/255.0, blue: 0/255.0, alpha: 1)
        if currentProfile_?.weeklyEarnedPoints == 0 {
            goalHeaderLabel.text = "Eat healthy, collect points!"
            pointsLabel.text = "Your weekly points will appear here"
            //goalPointsLabel.text = "Setup Weekly Goal"
            //setupGoalButton.isHidden = false
            pieColor = UIColor.lightGray
        }
        goalPointsLabel.text = "Goal: " + "\((currentProfile_?.goalPoints)!)" + "Pts"
        
        if pieLayer.values != nil && pieLayer.values.count == 2 {
            pieLayer.deleteValues([pieLayer.values[0], pieLayer.values[1]], animated: true)
        }
        let greyPoints = Float((currentProfile_?.goalPoints)! - (currentProfile_?.weeklyEarnedPoints)!)

        pieLayer.addValues([PieElement(value: Float((currentProfile_?.weeklyEarnedPoints)!), color: pieColor),
                            PieElement(value: greyPoints, color: UIColor.lightGray)], animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let weekdays = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
        let dayPoints = [5.0, 10.0, 15.0, 7.0, 20.0, 10.0, 5.0]
        chartsView.noDataText = "See your weekly points here"

        let limitLine = ChartLimitLine(limit: 0, label: "")
        limitLine.lineColor = UIColor.white.withAlphaComponent(0.3)
        limitLine.lineWidth = 1

        chartsView.leftAxis.addLimitLine(limitLine)
        chartsView.drawGridBackgroundEnabled = false
        chartsView.setBarChartData(xValues: weekdays, yValues: dayPoints, label: "Weekdays")
        chartsView.delegate = self
        chartsView.animate(yAxisDuration: 0.9)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCameraClick(_ sender: Any) {
        let alertController =  UIAlertController()
        let  takePhotoButton = UIAlertAction(title: "Take Photo", style: .destructive, handler: { (action) -> Void in

            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera

            self.present(self.imagePicker, animated: true, completion: nil)

        })

        let galleryButton = UIAlertAction(title: "Choose From Photos", style: .cancel, handler: { (action) -> Void in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary

            self.present(self.imagePicker, animated: true, completion: nil)
        })


        alertController.addAction(takePhotoButton)
        alertController.addAction(galleryButton)

        self.navigationController!.present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let viewController = UIStoryboard(name: "CommonStoryboard", bundle: nil).instantiateViewController(withIdentifier: "AddPhotoView") as? TTAddPhotoTableViewController {
            viewController.photoImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            present(viewController, animated: true, completion: nil)
        }
    }

    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        //print("\(entry.value) in \(months[entry.xIndex])")
    }
}

//https://github.com/danielgindi/Charts/issues/1340
extension BarChartView {

    private class BarChartFormatter: NSObject, IAxisValueFormatter {

        var labels: [String] = []

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return labels[Int(value)]
        }

        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }

    func setBarChartData(xValues: [String], yValues: [Double], label: String) {

        var dataEntries: [BarChartDataEntry] = []

        for i in 0..<yValues.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: yValues[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSet: chartDataSet)

        let chartFormatter = BarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter

        self.data = chartData
    }
}
