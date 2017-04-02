//
//  ViewController.swift
//  HertzChauffeur
//
//  Created by Yamnel Serra on 4/1/17.
//  Copyright © 2017 Yamnel. All rights reserved.
//

import UIKit
import ConversationV1

let username = "4fb1fe78-67be-4d52-9261-f44222e8a9b1"
let password = "JWrL85EPu2Fh"
let version = "2017-04-01" // use today's date for the most recent version
let conversation = Conversation(username: username, password: password, version: version)
let workspaceID = "0d9d120b-0dc3-4f04-8ff0-2b10320a5269"
let failure = { (error: Error) in print(error) }

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    
    


}

