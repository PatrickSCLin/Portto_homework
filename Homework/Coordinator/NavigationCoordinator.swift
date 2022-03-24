//
//  NavigationCoordinator.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import Foundation
import UIKit

class NavigationCoordinator: Coordinable {
    var parent: NavigationCoordinator?
    var children: [NavigationCoordinator] = []
    var rootController: UINavigationController
    var navigationController: UINavigationController {
        return rootController
    }
    
    func start() {
        
    }
    
    func start(_ child: NavigationCoordinator) {
        
    }
    
    func finish() {
        
    }
    
    func finish(_ child: NavigationCoordinator) {
        
    }
    
    required init(_ rootController: UINavigationController) {
        self.rootController = rootController
    }
}


