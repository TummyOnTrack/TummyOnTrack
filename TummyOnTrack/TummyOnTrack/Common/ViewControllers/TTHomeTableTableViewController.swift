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
    
    @IBOutlet weak var weekSummaryLabel: UILabel!
    @IBOutlet weak var noChartsView: UIView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var setupGoalButton: UIButton!
    @IBOutlet weak var goalPointsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chartsView: BarChartView!
    @IBOutlet weak var whatDoYouEatTodayButton: UIButton!

    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var starImageView: UIImageView!
   
    @IBOutlet weak var rewardsImageView: UIImageView!
    
    var pieLayer : PieLayer! = nil
    var imagePicker: UIImagePickerController!
    var weeklyFoodBlog: NSMutableDictionary?

    let weekdays = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]
    var dayPoints = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        noChartsView.layer.borderColor = UIColor.lightGray.cgColor
        noChartsView.layer.borderWidth = 1
        noChartsView.layer.cornerRadius = 3
        whatDoYouEatTodayButton.layer.cornerRadius = 3
        
        initializeNavigationBarTitleView()

        // load default food items
        loadFoodItems()

        pieLayer = PieLayer()
        pieLayer.frame = pieView.frame
        pieLayer.minRadius = Float(pieView.frame.width/3)
        pieLayer.maxRadius = Float(pieView.frame.width/2)

        view.layer.addSublayer(pieLayer)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ProfileChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setCurrentProfileDetails), name: NSNotification.Name(rawValue: "ProfileChanged"), object: nil)
        
        setCurrentProfileDetails()
        
        // When like/unlike clicked from user page, then reflect that in the main feed page also
        /*[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MediaLiked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaLiked:) name:@"MediaLiked" object:nil];*/
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func initializeNavigationBarTitleView() {
        if let image_ = UIImage(named: "logo1") {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image_
            navigationItem.titleView = imageView
        }
    }

    func setToday() {
        let date = Date()
        let calendar = Calendar.current

 
        let day = calendar.component(.weekday, from: date)
        
        let key_ = "weeklyPointsReset_" + (TTProfile.currentProfile?.name)!
        // Sunday
        if day == 1 {
            
            // reset weekly points on every Sunday
            let defaults = UserDefaults.standard
            let weekPointsFlag = defaults.object(forKey: "weeklyPointsReset")
            if weekPointsFlag == nil {
                TTProfile.currentProfile?.updateProfile(dictionary: ["weeklyEarnedPoints": 0])
                let defaults = UserDefaults.standard
                defaults.set("true", forKey: key_)
                defaults.synchronize()
            }
        } else {
            let defaults = UserDefaults.standard
            let weekPointsFlag = defaults.object(forKey: key_)
            if weekPointsFlag != nil {
                defaults.removeObject(forKey: key_)
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
                DispatchQueue.main.async {
                    _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                        self.getPushPermission()
                    }
                }
                
                
           
            }
        }
    }
    
    func getPushPermission() {
        let center = UNUserNotificationCenter.current()
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
        slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        alert.view.addSubview(slider)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
            self.goalPointsLabel.text = "Goal: " + "\(Int(slider.value))" + "Pts"
            TTProfile.currentProfile?.setGoalPoints(aGoalPoints: Int(slider.value))
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func sliderValueDidChange(_ sender:UISlider!)
    {
        print("Slider value changed")
        goalPointsLabel.text = "Goal: \(Int(sender.value))Pts"
    }

    func setCurrentProfileDetails() {
        populateProfileInfo()

        /*TTUser.currentUser?.getProfiles(success: { (aProfiles: [TTProfile]) in
            
        }) { (error: Error) in
            
        }*/
        
        populateCharts()
    }

    func populateProfileInfo() {
        guard let currentProfile = TTProfile.currentProfile  else {
            return
        }
        setToday()
        profileNameLabel.text = currentProfile.name?.capitalized
        
        if let profileImageURL = currentProfile.profileImageURL {
            profileImageView.setImageWith(profileImageURL)
        }
    }
    
    func populatePoints() {
        guard let currentProfile = TTProfile.currentProfile  else {
            return
        }
        var pieColor = themeColor
        if currentProfile.weeklyEarnedPoints == 0 {
            goalHeaderLabel.text = "Eat Healthy, Collect Points!"
            pointsLabel.text = "Your weekly points will appear here"
            pieColor = UIColor.lightGray
        } else {
            pointsLabel.text = "You earned \(currentProfile.weeklyEarnedPoints) points this week!"
            if currentProfile.weeklyEarnedPoints > currentProfile.goalPoints/2 {
                goalHeaderLabel.text = "Well done! Half way through!"
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

    }
    
    func populateCharts() {
        weeklyFoodBlog = [:]
        dayPoints = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        noChartsView.isHidden = false
        self.weekSummaryLabel.text = "Tracking Weekly Meals Made Easier!"
        TTProfile.currentProfile?.getWeeklyFoodBlog(success: { (aFoodBlog: [TTDailyFoodEntry]) in
            if aFoodBlog.count > 0 {
                for i in 0...(aFoodBlog.count-1) {
                    let blog = aFoodBlog[i]
                    self.dayPoints[blog.weekDay!-1] = self.dayPoints[blog.weekDay!-1] + Double(blog.earnedPoints!)
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
                self.noChartsView.isHidden = true
                self.setTrackingAlarm()
                self.weekSummaryLabel.text = "This Week's Summary"
            }
            let limitLine = ChartLimitLine(limit: 0, label: "")
            limitLine.lineColor = UIColor.white.withAlphaComponent(0.3)
            limitLine.lineWidth = 1
            
            self.chartsView.leftAxis.addLimitLine(limitLine)
            self.chartsView.xAxis.labelFont = UIFont(name: "Helvetica", size: 15)!
            
            self.chartsView.chartDescription?.text = "Daily Points"
            self.chartsView.chartDescription?.font = UIFont(name: "Helvetica", size: 14)!
            self.chartsView.setBarChartData(xValues: self.weekdays, yValues: self.dayPoints, label: "Weekdays")
            self.chartsView.delegate = self
            self.chartsView.animate(yAxisDuration: 0.9)
            
            self.populatePoints()
            
            
            
        }, failure: { (error: Error) in
            
        })

    }
    
    @IBAction func onImageTap(_ sender: UITapGestureRecognizer) {
        print("image tapped")
        //animateAchievement()
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
    
    func animateAchievement() {
        
            // create a square image view
        let square1 = UIImageView()
        square1.frame = CGRect(x: 180, y: 400, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
            // Add image to the square
        square1.image = UIImage(named: "Duckling-1x")
        self.view.addSubview(square1)
        
        let square2 = UIImageView()
        square2.frame = CGRect(x: 180, y: 400, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
        // Add image to the square
        square2.image = UIImage(named: "Hippo-1x")
        self.view.addSubview(square2)
        
        let square3 = UIImageView()
        square3.frame = CGRect(x: 180, y: 400, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
        // Add image to the square
        square3.image = UIImage(named: "Gorilla-1x")
        self.view.addSubview(square3)
        
        let square4 = UIImageView()
        square4.frame = CGRect(x: 180, y: 400, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
        // Add image to the square
        square4.image = UIImage(named: "Cat-1x")
        self.view.addSubview(square4)

        UIView.animate(withDuration: 0.5, animations: {
            square1.frame = CGRect(x: 0, y: 30, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
            square2.frame = CGRect(x: 300, y: 30, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
            square3.frame = CGRect(x: 140, y: 30, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
            square4.frame = CGRect(x: 200, y: 30, width: self.rewardsImageView.frame.size.width, height: self.rewardsImageView.frame.size.height)
        })
            
        
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
