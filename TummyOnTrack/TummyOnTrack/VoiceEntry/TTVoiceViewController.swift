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

class TTVoiceViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var userSpeechToTextLabel: UILabel!

    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var awesomeLabel: UILabel!
    var utterance: AVSpeechUtterance!
    var synthesizer: AVSpeechSynthesizer!
    let speechText = "What did you have today?"
    var selectedfoodstring = String()
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
            audioEngine.stop()
            recognitionRequest?.endAudio()
         //   microphoneButton.isEnabled = false
          //  microphoneButton.setTitle("P", for: .normal)
            awesomeLabel.isHidden = false
        }
        else {
         //   userSpeechToTextLabel.text = ""
            startRecording()
          //  microphoneButton.setTitle("S", for: .normal)
        }

    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        awesomeLabel.isHidden = true
        microphoneButton.layer.cornerRadius = microphoneButton.frame.size.width / 2

        //disable the microphone button until the speech recognizer is activated
        microphoneButton.isEnabled = false
        speechRecognizer?.delegate = self
        
        utterance = AVSpeechUtterance(string: speechText)
        synthesizer = AVSpeechSynthesizer()
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        //   utterance.rate = 0.5

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
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
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
                //   self.textView.text = result?.bestTranscription.formattedString
    
                self.userSpeechToTextLabel.text = result?.bestTranscription.formattedString
                self.selectedfoodstring = (result?.bestTranscription.formattedString)!
                isFinal = (result?.isFinal)!
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
    
    override func viewDidAppear(_ animated: Bool) {
        synthesizer.speak(utterance)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVoiceSummary" {
            let navigationVC = segue.destination as! UINavigationController
            let destinationVC = navigationVC.topViewController as! TTVoiceSummaryViewController
            destinationVC.selectedFoodString = self.selectedfoodstring.lowercased()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
