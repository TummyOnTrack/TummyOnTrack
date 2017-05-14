//
//  TTVoiceViewController.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/26/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit
import Speech
import Firebase

class TTVoiceViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    

    @IBOutlet weak var rightArrowTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightArrowImage: UIImageView!
    @IBOutlet weak var upArrowImage: UIImageView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var userSpeechToTextLabel: UILabel!
    @IBOutlet weak var whatDidEatLabel: UILabel!
    @IBOutlet weak var rippleView: UIView!
    var utterance: AVSpeechUtterance!
    var synthesizer: AVSpeechSynthesizer!
    var selectedfoodstring = String()
    var isSpeechRecognizerAuthorized = false
    var isMicrophoneAuthorized = false
    var viewSummaryEnabled = false
    let notificationForUpArrow = "startAnimatingUpArrow"
    let notificationForRightArrow = "startAnimatingRightArrow"
    var originalRightArrowCenter: CGPoint!
    var originalUpArrowCenter: CGPoint!
  //  var originalTopConstraint: NSLayoutConstraint!
 //   var newTopConstraint: NSLayoutConstraint!
    var originalConstraintConstant = CGFloat()
    var originalRightArrowConstraint: NSLayoutConstraint!
    
    //object that handles speech recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    //object handles the speech recognition requests. It provides an audio input to the speech recognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    //recognition task where it gives the result of the recognition request. Having this object is handy as you can cancel or stop the task.
    private var recognitionTask: SFSpeechRecognitionTask?
    //audio engine is responsible for providing your audio input
    private let audioEngine = AVAudioEngine()

    @IBAction func microphoneButton(_ sender: UIButton) {
        setupViewsForRippleEffect()
        
        if audioEngine.isRunning {
            audioEngine.pause()
            settingsToPauseRecording()
        }
        else {
            do {
                try audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            rightArrowImage.isHidden = false
            settingsToStartRecording()
        }

    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.title = "View Summary"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        rightArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        originalUpArrowCenter = upArrowImage.center
        originalRightArrowCenter = rightArrowImage.center
        upArrowImage.isHidden = true
        rightArrowImage.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(animateUpArrow), name: NSNotification.Name(rawValue: notificationForUpArrow), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animateRightArrow), name: NSNotification.Name(rawValue: notificationForRightArrow), object: nil)
        
        whatDidEatLabel.layer.cornerRadius = whatDidEatLabel.frame.height/2
        whatDidEatLabel.layer.masksToBounds = true
        
        microphoneButton.layer.cornerRadius = microphoneButton.frame.size.width / 2
        TTFoodItem.voiceSelectedFoodItems.removeAll()

        //disable the microphone button until the speech recognizer is activated
        microphoneButton.isEnabled = false
        
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        
        speechRecognizer?.delegate = self

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        //check if device has an audio input for recording
        guard audioEngine.inputNode != nil else {
            fatalError("Audio engine has no input node")
        }
        
        //request the authorization of Speech Recognition
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            }
            
            OperationQueue.main.addOperation() {
                self.isSpeechRecognizerAuthorized = isButtonEnabled
                self.microphoneButton.isEnabled = false
                
                let status = AVAudioSession.sharedInstance().recordPermission()
                switch status {
                case AVAudioSessionRecordPermission.denied:
                    print("User denied microphone access")
                case AVAudioSessionRecordPermission.granted:
                    print("User authorized microphone access")
                    self.isMicrophoneAuthorized = true
                default:
                    print("Microphone access not yet authorized")
                }
                
                if self.isSpeechRecognizerAuthorized && self.isMicrophoneAuthorized {
                    self.utterance = AVSpeechUtterance(string: "What did you eat today?")
                    self.utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    self.synthesizer.speak(self.utterance)
                }
                else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        originalUpArrowCenter = upArrowImage.center
        originalConstraintConstant = topConstraint.constant
        originalRightArrowCenter = rightArrowImage.center
        originalRightArrowConstraint = rightArrowTrailingConstraint
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateUpArrow() {
        upArrowImage.isHidden = false
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat], animations: {
            self.upArrowImage.center.y = self.originalUpArrowCenter.y + 12.0
            self.upArrowImage.center.y = self.originalUpArrowCenter.y
        }, completion: nil)
    }
    
    func animateRightArrow() {
        rightArrowImage.isHidden = false
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat], animations: {
            self.rightArrowImage.center.x = self.originalRightArrowCenter.x
            self.rightArrowImage.center.x = self.originalRightArrowCenter.x + 12.0
        }, completion: nil)
        
    }
    
    func setupViewsForRippleEffect() {
        rippleView.layer.cornerRadius = rippleView.frame.size.width / 2
        rippleView.clipsToBounds = true
        rippleView.layer.backgroundColor = UIColor.orange.withAlphaComponent(0.5).cgColor
        animateRippleEffect()
        
    }
    
    func animateRippleEffect() {
        rippleView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 1.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.rippleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            let alpha = (self.rippleView.layer.backgroundColor?.alpha)! / 10
            self.rippleView.layer.backgroundColor = UIColor.orange.withAlphaComponent(alpha).cgColor
        }) { (success: Bool) in
            self.rippleView.layer.backgroundColor = UIColor.orange.withAlphaComponent(0).cgColor
            
        }
    }
    
    // This method will be called when the availability changes. If speech recognition is available, the record button will also be enabled
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
            synthesizer.speak(utterance)
        }
        else {
            microphoneButton.isEnabled = false
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        //would require it to pass audio data to Apple’s servers
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        //check if device has an audio input for recording
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        //Tell recognitionRequest to report partial results of speech recognition as the user speaks
        recognitionRequest.shouldReportPartialResults = true
        
        //completion handler will be called every time the recognition engine has received input, has refined its current recognition, or has been canceled or stopped, and will return a final transcript
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false

            if result != nil {
                self.userSpeechToTextLabel.text = result?.bestTranscription.formattedString
                self.selectedfoodstring = (result?.bestTranscription.formattedString)!
                isFinal = (result?.isFinal)!
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.notificationForRightArrow), object: nil)
            }
            
            if isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneButton.isEnabled = true
                
            }

            if error != nil {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneButton.isEnabled = true
            }
        })

        //audio input to the recognitionRequest
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }

    func settingsToStartRecording() {
        let image = UIImage(named: "pause")
        microphoneButton.setImage(image, for: .normal)
        upArrowImage.isHidden = true
        rightArrowImage.isHidden = true
        topConstraint.constant = originalConstraintConstant
    }

    func settingsToPauseRecording() {
        if self.viewSummaryEnabled == false {
            self.viewSummaryEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationForUpArrow), object: nil)
        topConstraint.constant = originalConstraintConstant + 48.0
    
        rightArrowImage.isHidden = true
        let image = UIImage(named: "microphone")
        microphoneButton.setImage(image , for: .normal)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.microphoneButton.isEnabled = true

        if !(audioEngine.isRunning) {
            settingsToStartRecording()
            startRecording()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVoiceSummary" {
            TTFoodItem.getFoodItemsFromSpokenString(selectedFoodString: selectedfoodstring.capitalized)
            settingsToPauseRecording()
            audioEngine.stop()
            recognitionRequest?.endAudio()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationForRightArrow), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationForUpArrow), object: nil)

            let destinationVC = segue.destination as! TTVoiceSummaryViewController
            destinationVC.selectedFoodString = self.selectedfoodstring.lowercased()
        }
    }
}
