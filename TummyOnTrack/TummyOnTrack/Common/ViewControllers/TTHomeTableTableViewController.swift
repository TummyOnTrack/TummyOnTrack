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

class TTHomeTableTableViewController: UITableViewController, UINavigationControllerDelegate, ChartViewDelegate {
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var setupGoalButton: UIButton!
    @IBOutlet weak var goalPointsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var chartsView: BarChartView!

    var pieLayer : PieLayer! = nil
    var imagePicker: UIImagePickerController!
    var weeklyFoodBlog: NSMutableDictionary?

    let weekdays = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2

        // load default food items
        loadFoodItems()

        setTrackingAlarm()

        pieLayer = PieLayer()
        pieLayer.frame = pieView.frame
        pieLayer.minRadius = Float(pieView.frame.width/3)
        pieLayer.maxRadius = Float(pieView.frame.width/2)

        view.layer.addSublayer(pieLayer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setToday()
        setCurrentProfileDetails()
    }

    func setToday() {
        let date = Date()
        let calendar = Calendar.current

 
        let day = calendar.component(.weekday, from: date)
        // Sunday
        if day == 1 {
            // reset weekly points on every Sunday
            let defaults = UserDefaults.standard
            let weekPointsFlag = defaults.object(forKey: "weeklyPointsReset")
            if weekPointsFlag == nil {
                TTProfile.currentProfile?.updateProfile(dictionary: ["weeklyEarnedPoints": 0])
                let defaults = UserDefaults.standard
                defaults.set("true", forKey: "weeklyPointsReset")
                defaults.synchronize()
            }
        } else {
            let defaults = UserDefaults.standard
            let weekPointsFlag = defaults.object(forKey: "weeklyPointsReset")
            if weekPointsFlag != nil {
                defaults.removeObject(forKey: "weeklyPointsReset")
                defaults.synchronize()
            }
        }
        
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

    @IBAction func onWhatDidEatClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "VoiceEntry", bundle: nil).instantiateViewController(withIdentifier: "TTVoiceViewController") as? TTVoiceViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
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
        populateProfileInfo()

        TTUser.currentUser?.getProfiles(success: { (aProfiles: [TTProfile]) in
            
        }) { (error: Error) in
            
        }
    }

    func populateProfileInfo() {
        guard let currentProfile = TTProfile.currentProfile  else {
            return
        }

        profileNameLabel.text = currentProfile.name?.capitalized

        if let profileImageURL = currentProfile.profileImageURL {
            profileImageView.setImageWith(profileImageURL)
        }

        var pieColor = themeColor
        if currentProfile.weeklyEarnedPoints == 0 {
            goalHeaderLabel.text = "Eat healthy, collect points!"
            pointsLabel.text = "Your weekly points will appear here"
            pieColor = UIColor.lightGray
        } else {
            pointsLabel.text = "You earned \(currentProfile.weeklyEarnedPoints) points this week!"
            if currentProfile.weeklyEarnedPoints > currentProfile.goalPoints/2 {
                goalHeaderLabel.text = "Awesome! You are half way through!"
            }
        }

        goalPointsLabel.text = "Goal: \(currentProfile.goalPoints)Pts"
        
        if pieLayer.values != nil && pieLayer.values.count == 2 {
            pieLayer.deleteValues([pieLayer.values[0], pieLayer.values[1]], animated: true)
        }

        let greyPoints = Float(currentProfile.goalPoints - currentProfile.weeklyEarnedPoints)

        pieLayer.addValues([PieElement(value: Float(currentProfile.weeklyEarnedPoints), color: pieColor),
                            PieElement(value: greyPoints, color: UIColor.lightGray)], animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var dayPoints = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        weeklyFoodBlog = [:]
        TTProfile.currentProfile?.getWeeklyFoodBlog(success: { (aFoodBlog: [TTDailyFoodEntry]) in
            if aFoodBlog.count > 0 {
                for i in 0...(aFoodBlog.count-1) {
                    let blog = aFoodBlog[i]
                    dayPoints[blog.weekDay!-1] = dayPoints[blog.weekDay!-1] + Double(blog.earnedPoints!)
                    self.chartsView.noDataText = "See your weekly points here"
                    
                    let dictBlog_ = self.weeklyFoodBlog?.object(forKey: self.weekdays[blog.weekDay!-1])
                    
                    if dictBlog_ == nil {
                        let dictArray_: NSMutableArray = []
                        dictArray_.add(blog)
                        
                        self.weeklyFoodBlog?.setObject(dictArray_, forKey: self.weekdays[blog.weekDay!-1] as NSCopying)
                    }
                    else {
                        let dictArray_: NSMutableArray = dictBlog_ as! NSMutableArray
                        dictArray_.add(blog)

                        self.weeklyFoodBlog?.setObject(dictArray_, forKey: self.weekdays[blog.weekDay!-1] as NSCopying)
                    }
                }
            }
            
            let limitLine = ChartLimitLine(limit: 0, label: "")
            limitLine.lineColor = UIColor.white.withAlphaComponent(0.3)
            limitLine.lineWidth = 1
            
            self.chartsView.leftAxis.addLimitLine(limitLine)
            self.chartsView.xAxis.labelFont = UIFont(name: "Helvetica", size: 15)!

            self.chartsView.chartDescription?.text = "Daily Food Points"
            self.chartsView.setBarChartData(xValues: self.weekdays, yValues: dayPoints, label: "Weekdays")
            self.chartsView.delegate = self
            self.chartsView.animate(yAxisDuration: 0.9)
        }, failure: { (error: Error) in
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        performSegue(withIdentifier: "Show Plate View", sender: self.weekdays[Int(entry.x)])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Show Plate View") {
            
            let vc_ = segue.destination as! TTFillPlateViewController
            vc_.dayOfWeek = sender as! String
            if self.weeklyFoodBlog?.object(forKey: sender as! String) != nil {
                vc_.foodBlog = (self.weeklyFoodBlog?.object(forKey: sender as! String) as? [TTDailyFoodEntry])!
            }
            else {
                vc_.foodBlog = []
            }
        }
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
        //var valueColors = [UIColor]()
        for i in 0..<yValues.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: yValues[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.valueFont = UIFont(name: "Helvetica-Bold", size: 15)!
        
        let chartData = BarChartData(dataSet: chartDataSet)
        let chartFormatter = BarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.rightAxis.enabled = false
        self.data = chartData
    }
    
    func colorPicker(value : Double) -> UIColor {
        //input your own logic for how you actually want to color the x axis
        if value == 3 {
            return UIColor.red
        }
        else {
            return UIColor.black
        }
    }
}
