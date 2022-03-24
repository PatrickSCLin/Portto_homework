//
//  AppCoordinator.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import UIKit
import RxSwift

class AppCoordinator: NavigationCoordinator {
    enum Action {
        case showDetail(_ info: AssetInfo)
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: Private Methods
    
    private func showDetail(_ info: AssetInfo) {
        let coordinator = AssetCoordinator(navigationController, info)
        coordinator.parent = self
        coordinator.start()
    }
    
    // MARK: Public Methods
    
    override func start() {
        let viewModel = AssetsViewModel()
        
        viewModel.output.didSelectedAsset
            .asObservable()
            .do(onNext: { [weak self] info in
                self?.showDetail(info)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        let viewController = AssetsViewController(viewModel)
        rootController.viewControllers = [viewController]
    }
    
    override func start(_ child: NavigationCoordinator) {
        children.append(child)
    }
    
    override func finish(_ child: NavigationCoordinator) {
        guard let index = children.firstIndex(where: { coordinator in
            return coordinator === child
        }) else {
            return
        }
        
        child.parent = nil
        children.remove(at: index)
    }
    
    func perform(_ action: Action) {
        switch action {
        case let .showDetail(info):
            showDetail(info)
        }
    }
}
