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


//
let username = "4fb1fe78-67be-4d52-9261-f44222e8a9b1"
let password = "JWrL85EPu2Fh"
let version = "2017-04-01" // use today's date for the most recent version
let conversation = Conversation(username: username, password: password, version: version)
let workspaceID = "0d9d120b-0dc3-4f04-8ff0-2b10320a5269"
let failure = { (error: Error) in print(error) }

class ViewController: UIViewController {
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var myTextView: UITextView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var speechRecognitionRequest:
    SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var textToSendToWatson: String = ""
    private let commands: [String] = ["unlock my car"];
    
    @IBAction func startTranscribing(_sender: AnyObject) {
        transcribeButton.isEnabled = false;
        stopButton.isEnabled = true;
        try! startSession()
    }
    
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
        speechRecognitionTask = speechRecognizer.recognitionTask(with:
        recognitionRequest) { result, error in
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
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
        { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.speechRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        //get the audio engine to stop running
        
    }
    
    @IBAction func stopTranscribing(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            speechRecognitionRequest?.endAudio()
            transcribeButton.isEnabled = true
            stopButton.isEnabled = false
            
            textToSendToWatson = myTextView.text.lowercased();
            print(textToSendToWatson.lowercased());
            print(validateCommand(textToValidate: textToSendToWatson.lowercased()))
        }
    }
    
    func validateCommand(textToValidate: String) -> BooleanLiteralType {
        for string in commands {
            if textToValidate == string {
                return true;
            }
        }
        return false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeSpeechRecognition()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        var context: Context? // save context to continue conversation
        conversation.message(withWorkspace: workspaceID, failure: failure) { response in
            print(response.output.text)
            context = response.context
        }
        
        let text = "Turn the car on for me"
        let request = MessageRequest(text: text, context: context)
        conversation.message(withWorkspace: workspaceID, request: request, failure: failure) {
            response in
            print(response.output.text)
            context = response.context
        }
        
        print(context?.toJSON() ?? "Error")
        
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
                    self.transcribeButton.isEnabled = true
                case .denied:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition access denied by user", for: .disabled)
                case .restricted:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition restricted on, device", for: .disabled)
                case .notDetermined:
                    self.transcribeButton.isEnabled = false
                    self.transcribeButton.setTitle("Speech recognition not authorized", for: .disabled)
                }
            }
        }
    }
}

