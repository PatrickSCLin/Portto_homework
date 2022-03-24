//
//  Coordinator.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import UIKit
import Alamofire

protocol Coordinable {
    associatedtype RootController
    associatedtype Coordinator
    
    var parent: Coordinator? { set get }
    var children: [Coordinator] { set get }
    var rootController: RootController { get }
    
    func start()
    init(_ rootController: RootController)
}
