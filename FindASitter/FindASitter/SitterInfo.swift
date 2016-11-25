//
//  SitterInfo.swift
//  FindASitter
//
//  Created by Active Mac05 on 14/10/16.
//  Copyright © 2016 techactive. All rights reserved.
//

import Foundation

class SitterInfo: NSObject {
    var profileImage : String!
    var name : String!
    var age : String!
    var rating : Float!
    
    init(profileImage : String, name : String, age : String, rating : Float) {
        self.profileImage=profileImage
        self.name=name
        self.age=age
        self.rating=rating
    }
    
    override var description : String {
        return " name = \(self.name) , age = \(self.age), rating = \(self.rating)"
    }
    
    override var debugDescription : String {
        return " name = \(self.name) , age = \(self.age), rating = \(self.rating)"
    }
}
