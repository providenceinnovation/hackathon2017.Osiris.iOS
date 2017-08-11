//
//  OsirisService.swift
//  Osiris
//
//  Created by Barry on 8/9/17.
//  Copyright © 2017 Barry. All rights reserved.
//

import Foundation
import Firebase

//fileprivate let localURL = "http://localhost:8080/send"
//fileprivate let osirisURL = "https://osiris-26b00.firebaseio.com/providers/examplenew123.json"

typealias UpdateCallback = (OsirisModel) -> Void

let service: OsirisService =  { return OsirisService() }()

class  OsirisService {
    var onUpdate: ((OsirisModel) -> Void)? = nil
    var db: DatabaseReference!
    private var providerRef: DatabaseReference? = nil
    private var realtimeRef: DatabaseReference? = nil
    private var model: OsirisModel?
    
    init() {
        db = Database.database().reference()
        setProvider(name: "wa211119151")
    }
    
    func setProvider(name: String) {
        providerRef = self.db.child(name)
        realtimeRef = self.db.child("realtime").child(name)
        realtimeRef?.observe(.value) { [weak self] (snapshot: DataSnapshot) in
            if let model = OsirisService.model(fromSnapshot: snapshot) {
                self?.model = model
                self?.onUpdate?(model)
            }
        }
    }

     private class func model(fromSnapshot snapshot: DataSnapshot) -> OsirisModel? {
        guard let numberOfBeds = snapshot.childSnapshot(forPath: "numberOfBeds/value").value as? Int,
            let waitTime = snapshot.childSnapshot(forPath: "waitTime/value").value as? Int,
            let acceptingNow = snapshot.childSnapshot(forPath: "acceptingNow/value").value as? Bool
            else {
                return nil
        }
        
        let model = OsirisModel(numberOfBeds: numberOfBeds, waitTime: waitTime, acceptingNow: acceptingNow)
        return model
    }
    
    func send(isAccepting: Bool) {
         realtimeRef?.updateChildValues([ "acceptingNow/value" : isAccepting])
    }
    
    @IBAction func incrementNumberOfBeds() {
        if let beds = model?.numberOfBeds {
            send(numberOfBeds: beds + 1)
        }
    }
    
    @IBAction func decrementNumberOfBeds() {
        if let beds = model?.numberOfBeds {
            send(numberOfBeds: max(0, beds - 1))
        }
    }
    
    func send(numberOfBeds: Int) {
        
        var updates: Dictionary<String,Any> = [ "numberOfBeds/value" : numberOfBeds]
        
        if numberOfBeds == 0 {
            updates["acceptingNow/value"] = false
        }
        realtimeRef?.updateChildValues(updates)
    }
    
    func send(waitTime: Int) {
        realtimeRef?.updateChildValues([ "waitTime/value" : waitTime])
    }
    
}
