//
//  ViewController.swift
//  HertzChauffeur
//
//  Created by Yamnel Serra on 4/1/17.
//  Copyright © 2017 Yamnel. All rights reserved.
//

import UIKit
import ConversationV1
import Speech
import RestKit
import Firebase


// IMB's Watson Credentials
let username = "4fb1fe78-67be-4d52-9261-f44222e8a9b1"
let password = "JWrL85EPu2Fh"
let version = "2017-04-01" // use today's date for the most recent version
// Start Conversation App
let conversation = Conversation(username: username, password: password, version: version)

// App ID
let workspaceID = "0d9d120b-0dc3-4f04-8ff0-2b10320a5269"
let failure = { (error: Error) in print(error) } // for Fail message and logs

//Initializes reference to Firebase object
let ref  : FIRDatabaseReference! = FIRDatabase.database().reference()

class ViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var myTextView: UITextView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var textToSendToWatson: String = ""
    private var rawReplyFromWatson: Context?
    private var replyFromWatson: [String]?
    
    var systemToChange: String? // What we car system we want to change
    var systemValue: String?  // What we are changing it to
    
    var values: [String:Any] = [:]
    
    @IBAction func startTranscribing(_sender: AnyObject) {
        startBtn.isEnabled = false;
        stopButton.isEnabled = true;
        try! startSession()
    }
    
    
    // Starts listening
    func startSession() throws {
        
        
        if let recognitionTask = speechRecognitionTask {
            recognitionTask.cancel()
            self.speechRecognitionTask = nil
        }
        
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = speechRecognitionRequest else {
            fatalError("SFSpeechAudioBufferRecognitionRequest object creation failed") }
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        
        recognitionRequest.shouldReportPartialResults = true
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
                self.startBtn.isEnabled = true
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.speechRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    
    // database syncronization
    func pushToDB (system: String, value: String){
        
        print("\nSent \(system) and \(value)")  // testing
        
        if(system == "text"){
            // we'll display the text but not push
            
        }else{
            
            if(system == "Engine" || system == "Lock"){
                
                if (value == "True"){
                    
                    values  = ["\(system)": true]
               
                } else if (value == "False"){
                    
                    values  = ["\(system)": false]
                }
            
            } else if(system == "Speed" || system == "Volume" || system == "airTemp" || system == "fanSpeed"){
                
                values  = ["\(system)": Int(value)!]
            }
    
        ref.child("Yamnel").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
            if err != nil {
                        
                print(err!)
                        
                return
            }
                    
        })
        
        }
    }
    
    
    
    @IBAction func stopTranscribing(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            speechRecognitionRequest?.endAudio()
            startBtn.isEnabled = true
            stopButton.isEnabled = false
            
            textToSendToWatson = myTextView.text.lowercased();
            
            print(textToSendToWatson.lowercased()); // Testing
            
            sendToWatson(voiceCommand: textToSendToWatson)
            
        }
    }
    
    
    
    
    func sendToWatson(voiceCommand: String) {
        var rawAnswer: Context?
        var sys: String = ""
        var value: String = ""
        
        conversation.message(withWorkspace: workspaceID, failure: failure) { response in
            rawAnswer = response.context
        }
        
        let request = MessageRequest(text: voiceCommand, context: rawAnswer)
        
        conversation.message(withWorkspace: workspaceID, request: request, failure: failure) {
            response in
            
            self.replyFromWatson = response.output.text
            
            if self.replyFromWatson != nil && !(self.replyFromWatson?.isEmpty)!{
                let reply: String = self.replyFromWatson![0]
                
                sys = reply.components(separatedBy: " ").first!
                value = reply.components(separatedBy: " ").last!
                
                print("\(sys) is going to get passed to the DB")
                print("\(value) is going to get passed to the DB")
                
            }
            
            if sys != ""{
                self.pushToDB(system: sys, value: value)
            }
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeSpeechRecognition()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func authorizeSpeechRecognition() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startBtn.isEnabled = true
                case .denied:
                    self.startBtn.isEnabled = false
                    self.startBtn.setTitle("Speech recognition access denied by user", for: .disabled)
                case .restricted:
                    self.startBtn.isEnabled = false
                    self.startBtn.setTitle("Speech recognition restricted on, device", for: .disabled)
                case .notDetermined:
                    self.startBtn.isEnabled = false
                    self.startBtn.setTitle("Speech recognition not authorized", for: .disabled)
                }
            }
        }
    }
}
