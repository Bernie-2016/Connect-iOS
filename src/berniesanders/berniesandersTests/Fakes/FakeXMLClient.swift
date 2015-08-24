import berniesanders
import Foundation
import KSDeferred

class FakeXMLClient: berniesanders.XMLClient {
    private (set) var deferredsByURL = [NSURL: KSDeferred]()
    
    func fetchXMLDocumentWithURL(url: NSURL) -> KSPromise {
        var deferred =  KSDeferred.defer()
        self.deferredsByURL[url] = deferred
        return deferred.promise
    }
}//
//  FakeXMLClient.swift
//  berniesanders
//
//  Created by Mike Stallard on 8/24/15.
//  Copyright (c) 2015 Bill Dwyer. All rights reserved.
//

import Foundation
