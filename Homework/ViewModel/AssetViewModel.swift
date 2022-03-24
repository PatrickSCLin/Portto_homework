//
//  AssetViewModel.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import RxSwift
import RxCocoa

protocol AssetViewModelInput {
    var openLink: AnyObserver<Void> { get }
    var finish: AnyObserver<Void> { get }
}

protocol AssetViewModelOutput {
    var asset: Driver<AssetInfo> { get }
    var needOpenLink: Signal<String> { get }
    var didFinish: Signal<Void> { get }
}

class AssetViewModel: ViewModelType {
    struct Input: AssetViewModelInput {
        let openLink: AnyObserver<Void>
        let finish: AnyObserver<Void>
    }
    
    struct Output: AssetViewModelOutput {
        let asset: Driver<AssetInfo>
        let needOpenLink: Signal<String>
        let didFinish: Signal<Void>
    }

    let input: Input
    let output: Output
    
    private let openLinkSubject: PublishSubject<Void>
    private let finishSubject: PublishSubject<Void>
    private let assetSubject: BehaviorSubject<AssetInfo>
    
    // MARK: Private Methods
    
    private func binding() {
        
        
    }
    
    // MARK: Init Methods
    
    init(_ info: AssetInfo) {
        openLinkSubject = .init()
        finishSubject = .init()
        assetSubject = .init(value: info)
        
        input = Input(openLink: openLinkSubject.asObserver(),
                      finish: finishSubject.asObserver())
        output = Output(asset: assetSubject.asDriver(onErrorDriveWith: .never()),
                        needOpenLink: openLinkSubject.flatMap { _ -> Observable<String> in
            guard let link = info.permalink else { return .never() }
            
            return .just(link)
        }.asSignal(onErrorSignalWith: .never()),
                        didFinish: finishSubject.asSignal(onErrorSignalWith: .never()))
        
        binding()
    }
}
