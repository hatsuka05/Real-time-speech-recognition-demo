//
//  ViewController.swift
//  demoSpeech
//
//  Created by Nguyen Thanh Tung on 4/30/17.
//  Copyright © 2017 tung3457. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController , SFSpeechRecognizerDelegate{

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var transcribeButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var myTextView: UITextView!
   
    
    private let speechRecognizer = SFSpeechRecognizer(locale:
        Locale(identifier: "en-US"))!
    
    private var speechRecognitionRequest:
    SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    func authorizeSR() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.transcribeButton.isEnabled = true
                    
                case .denied:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition access denied by user", for: .disabled)
                    
                case .restricted:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition restricted on device", for: .disabled)
                    
                case .notDetermined:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition not authorized", for: .disabled)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        authorizeSR()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startSession() throws {
        
        //
        if let recognitionTask = speechRecognitionTask {
            recognitionTask.cancel()
            self.speechRecognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = speechRecognitionRequest else { fatalError("SFSpeechAudioBufferRecognitionRequest object creation failed") }
        
        //
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        //recognition task is initialized
        speechRecognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            var finished = false
            
            if let result = result {
                self.myTextView.text =
                    result.bestTranscription.formattedString
                finished = result.isFinal
            }
            
            if error != nil || finished {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.speechRecognitionRequest = nil
                self.speechRecognitionTask = nil
                
                self.transcribeButton.isEnabled = true
            }
        }
        
        //
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            
            self.speechRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    @IBAction func startTranscribing(_ sender: Any) {
        transcribeButton.isEnabled = false
        stopButton.isEnabled = true
        try! startSession()
    }
    
    @IBAction func stopTranscribing(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            speechRecognitionRequest?.endAudio()
            transcribeButton.isEnabled = true
            stopButton.isEnabled = false
        }
    }
    
    @IBAction func btnView(_ sender: Any) {
        
        label.text = myTextView.text
    }
    
    
    
    
    

}

