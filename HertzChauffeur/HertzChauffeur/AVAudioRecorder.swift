//
//  AVAudioRecorder.swift
//  HertzChauffeur
//
//  Created by Stephen Lomangino on 4/1/17.
//  Copyright © 2017 Yamnel. All rights reserved.
//

import UIKit
import AVFoundation


class AVAudioRecorder: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playButton.isEnabled = false
        stopButton.isEnabled = false
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask);
        
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf");
        
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 2,AVSampleRateKey: 44100.0] as [String : Any];
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory( AVAudioSessionCategoryPlayAndRecord)
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
        do {
            audioRecorder = AVAudioRecorder();
            
            audioRecorder?.prepareToRecord();
            } catch let error as NSError
            { print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func recordAudio(_ sender: AnyObject) {
        if audioRecorder?.isRecording == false {
            playButton.isEnabled = false
            stopButton.isEnabled = true
            audioRecorder?.record()
            
        }
    }
    
    @IBAction func stopAudio(_ sender: AnyObject) {
        stopButton.isEnabled = false
        playButton.isEnabled = true
        recordButton.isEnabled = true
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }
    }
    
    @IBAction func playAudio(_ sender: AnyObject) {
        
        if audioRecorder?.isRecording == false {
            stopButton.isEnabled = true
            recordButton.isEnabled = false
            do { try audioPlayer = AVAudioPlayer(contentsOf: (audioRecorder?.url)!);
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
            } catch let error as NSError {
                    print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player:AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        stopButton.isEnabled = false
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
