//
//  AssetCoordinator.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/22.
//

import UIKit
import RxSwift

class AssetCoordinator: NavigationCoordinator {
    enum Action {
        case openlink(_ url: String)
    }
    
    private let info: AssetInfo
    private var disposeBag = DisposeBag()
    
    // MARK: Public Methods
    
    override func start() {
        let viewModel = AssetViewModel(info)
        
        viewModel.output.needOpenLink
            .asObservable()
            .do(onNext: { [weak self] link in
                self?.perform(.openlink(link))
            })
            .subscribe()
            .disposed(by: disposeBag)
                
        viewModel.output.didFinish
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.finish()
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        let viewController = AssetViewController(viewModel)
        navigationController.pushViewController(viewController, animated: true)
                
        parent?.start(self)
    }
    
    override func finish() {
        parent?.finish(self)
    }
    
    func perform(_ action: Action) {
        switch action {
        case let .openlink(link):
            guard let url = URL(string: link) else { return }
            
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: Init Methods
    
    init(_ rootController: UINavigationController, _ info: AssetInfo) {
        self.info = info
        super.init(rootController)
    }
    
    required init(_ rootController: UINavigationController) {
        fatalError("init(_:) has not been implemented")
    }
}
