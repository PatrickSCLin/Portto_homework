//
//  OpenSeaService.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import Moya
import RxSwift
import RxCocoa

protocol OpenSeaServiceInput {
    typealias AssetsQuery = (owner: String, cursor: String)
    
    var fetchAssets: AnyObserver<AssetsQuery> { get }
}

protocol OpenSeaServiceOutput {
    var assets: Driver<AssetsInfo> { get }
}

class OpenSeaService: ServiceType {
    struct Input: OpenSeaServiceInput {
        let fetchAssets: AnyObserver<AssetsQuery>
    }
    
    struct Output: OpenSeaServiceOutput {
        let assets: Driver<AssetsInfo>
    }
    
    let input: Input
    let output: Output
    
    private let provider: MoyaProvider<MultiTarget>
    private let fetchAssetsSubject: PublishSubject<OpenSeaServiceInput.AssetsQuery>
    private let assetsInfoSubject: ReplaySubject<AssetsInfo>
    
    private var disposeBag = DisposeBag()
    
    // MARK: Private Methods
    
    private func getAssets(_ owner: String, cursor: String) -> Single<AssetsInfo> {
        let target = OpenSeaAPI.assets(owner: owner, cursor: cursor)
        return provider.rx
            .request(MultiTarget(target))
            .map(AssetsInfo.self)
            .do (onSuccess: { [weak self] info in
                self?.assetsInfoSubject.onNext(info)
            })
    }
    
    private func binding() {
        _ = fetchAssetsSubject
            .flatMap { [weak self] query -> Single<AssetsInfo> in
                guard let self = self else { return .never() }
                
                return self.getAssets(query.owner, cursor: query.cursor)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: Init Methods
    
    init() {
        provider = MoyaProvider<MultiTarget>()
        
        fetchAssetsSubject = .init()
        assetsInfoSubject = .create(bufferSize: 1)
        
        input = Input(fetchAssets: fetchAssetsSubject.asObserver())
        output = Output(assets: assetsInfoSubject.asDriver(onErrorDriveWith: .empty()))
        
        binding()
    }
}
