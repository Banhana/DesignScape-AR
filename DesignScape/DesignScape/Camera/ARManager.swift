//
//  ARManager.swift
//  DesignScape
//
//  Created by Tony Banh on 2/3/24.
//

import Combine

class ARManager{
    static let shared = ARManager()
    private init() { }
    
    var actionStream = PassthroughSubject<ARActions, Never>()
}
