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

class TTHomeTableTableViewController: UITableViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,ChartViewDelegate {
    
    @IBOutlet weak var weekSummaryLabel: UILabel!
    @IBOutlet weak var noChartsView: UIView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var setupGoalButton: UIButton!
    @IBOutlet weak var goalPointsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var whatDoYouEatTodayButton: UIButton!

    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var starImageView: UIImageView!
   
    @IBOutlet weak var rewardsImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var pieLayer : PieLayer! = nil
    var imagePicker: UIImagePickerController!
    var weeklyFoodBlog: NSMutableDictionary?

    let weekdays = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]
    var dayPoints = [0, 0, 0, 0, 0, 0, 0]

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
        
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ProfileChanged"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(setCurrentProfileDetails), name: NSNotification.Name(rawValue: "ProfileChanged"), object: nil)
        
        //setCurrentProfileDetails()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentProfileDetails()
        
    }
    
    func initializeNavigationBarTitleView() {
        if let image_ = UIImage(named: "logo1") {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image_
            navigationItem.titleView = imageView
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
            self.goalPointsLabel.text = "\(TTProfile.currentProfile?.weeklyEarnedPoints ?? 0)" + " / " + "\(Int(slider.value))"
            TTProfile.currentProfile?.setGoalPoints(aGoalPoints: Int(slider.value))
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func sliderValueDidChange(_ sender:UISlider!)
    {
        print("Slider value changed")
        
        goalPointsLabel.text = "\(TTProfile.currentProfile?.weeklyEarnedPoints ?? 0)" + " / " + "\(Int(sender.value))"
    }

    func setCurrentProfileDetails() {
        populateProfileInfo()
        
        populateCharts()
    }

    func populateProfileInfo() {
        guard let currentProfile = TTProfile.currentProfile  else {
            return
        }
        //setToday()
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
        var greyColor = UIColor.lightGray
        if currentProfile.weeklyEarnedPoints == 0 {
            goalHeaderLabel.text = "Eat Healthy, Collect Points!"
            pointsLabel.text = "Your weekly points will appear here"
            pieColor = UIColor.lightGray
        } else {
            print(currentProfile.weeklyEarnedPoints)
            let greyPoints = Float(currentProfile.goalPoints - currentProfile.weeklyEarnedPoints)
            pointsLabel.text = "You earned \(currentProfile.weeklyEarnedPoints) points this week!"
            if currentProfile.weeklyEarnedPoints >= currentProfile.goalPoints {
                goalHeaderLabel.text = "Awesome! You did it!"
            }
            else if greyPoints <= 10 {
                goalHeaderLabel.text = "Keep going! Almost there!"
            }
            else if currentProfile.weeklyEarnedPoints > currentProfile.goalPoints/2 {
                goalHeaderLabel.text = "Well done! Half way through!"
            }
            else {
                goalHeaderLabel.text = "Eat Healthy, Collect Points!"
            }
        }
        
        goalPointsLabel.text = "\(currentProfile.weeklyEarnedPoints) / \(currentProfile.goalPoints)"
        
        if pieLayer.values != nil && pieLayer.values.count == 2 {
            pieLayer.deleteValues([pieLayer.values[0], pieLayer.values[1]], animated: true)
        }
        print(currentProfile.weeklyEarnedPoints)
        let greyPoints = Float(currentProfile.goalPoints - currentProfile.weeklyEarnedPoints)
        
        if greyPoints <= 0 {
            greyColor = themeColor
        }
        pieLayer.addValues([PieElement(value: Float(currentProfile.weeklyEarnedPoints), color: pieColor),
                            PieElement(value: greyPoints, color: greyColor)], animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func populateCharts() {
        print("populateChartsCalled")
        weeklyFoodBlog = [:]
        dayPoints = [0, 0, 0, 0, 0, 0, 0]
        noChartsView.isHidden = false
        self.weekSummaryLabel.text = "Tracking Weekly Meals Made Easier!"
        TTProfile.currentProfile?.getWeeklyFoodBlog(success: { (aFoodBlog: [TTDailyFoodEntry]) in
            if aFoodBlog.count > 0 {
                for i in 0...(aFoodBlog.count-1) {
                    let blog = aFoodBlog[i]
                    self.dayPoints[blog.weekDay!-1] = self.dayPoints[blog.weekDay!-1] + Int(blog.earnedPoints!)
                    
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
            
            self.collectionView.reloadData()
            self.populatePoints()
            
        }, failure: { (error: Error) in
            
        })

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekdayCell", for: indexPath) as! TTWeekdayCollectionViewCell
        cell.weekdayLabel.text = weekdays[indexPath.row].uppercased()
        cell.pointsLabel.text =  "\(dayPoints[indexPath.row])"
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: date)
        if day == indexPath.row + 1 {
            cell.weekdayLabel.textColor = themeColor
            cell.layer.borderColor = themeColor.cgColor
            cell.layer.borderWidth = 1
        }
        else {
            cell.weekdayLabel.textColor = UIColor.black
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
        }
        cell.alpha = 1
        if indexPath.row + 1 > day {
            cell.starImageView.image = nil
            cell.pointsLabel.text = ""
            cell.alpha = 0.7
        }
        else if dayPoints[indexPath.row] == 0 {
            cell.starImageView.image = UIImage(named: "Face_With_Rolling")
            cell.alpha = 0.7
        }
        else {
            cell.starImageView.image = UIImage(named: "Smiling_Face_Blushed")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dayPoints[indexPath.row] > 0 {
            performSegue(withIdentifier: "Show Food Summary", sender: self.weekdays[indexPath.row])
        }
    }

    
    @IBAction func onImageTap(_ sender: UITapGestureRecognizer) {
        print("image tapped")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if highlight.y > 0 {
            performSegue(withIdentifier: "Show Food Summary", sender: self.weekdays[Int(entry.x)])
        }
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
        if (segue.identifier == "Show Food Summary") {
            
            let vc_ = segue.destination as! TTFoodSummaryViewController
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

