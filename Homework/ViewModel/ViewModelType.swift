//
//  ViewModelType.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}
