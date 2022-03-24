//
//  AssetsViewModel.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import RxSwift
import RxCocoa

protocol AssetsViewModelInput {
    var fetchNext: AnyObserver<Void> { get }
    var selectedAsset: AnyObserver<AssetInfo> { get }
}

protocol AssetsViewModelOutput {
    var isFetching: Driver<Bool> { get }
    var assets: Driver<[AssetInfo]> { get }
    var didSelectedAsset: Signal<AssetInfo> { get }
}

class AssetsViewModel: ViewModelType {
    struct Input: AssetsViewModelInput {
        let fetchNext: AnyObserver<Void>
        let selectedAsset: AnyObserver<AssetInfo>
    }
    
    struct Output: AssetsViewModelOutput {
        let isFetching: Driver<Bool>
        let assets: Driver<[AssetInfo]>
        let didSelectedAsset: Signal<AssetInfo>
    }

    let input: Input
    let output: Output
    
    private let fetchNextSubject: PublishSubject<Void>
    private let selectedAssetSubject: PublishSubject<AssetInfo>
    private let isFetchSubject: BehaviorSubject<Bool>
    private let assetsSubject: BehaviorSubject<[AssetInfo]>
    
    private let service: OpenSeaService
    
    private var disposeBag = DisposeBag()
    private var owner = "0x19818f44faf5a217f619aff0fd487cb2a55cca65"
    private var cursor = ""
    private var shouldLoadMore = true
    
    // MARK: Private Methods
    
    private func binding() {
        _ = fetchNextSubject
            .flatMap { [weak self] a -> Observable<Void> in
                guard let self = self, let isFetching = try? self.isFetchSubject.value() else { return .empty() }
                
                return (self.shouldLoadMore && !isFetching) ? .just(()) : .empty()
            }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.isFetchSubject.onNext(true)
                self.service.input.fetchAssets.onNext((owner: self.owner,
                                                       cursor: self.cursor))
            })
            .subscribe()
            .disposed(by: disposeBag)
                
        _ = service.output.assets.asObservable()
            .do(onNext: { [weak self] info in
                guard let self = self else { return }
                
                let previous = (try? self.assetsSubject.value()) ?? []
                self.assetsSubject.onNext(previous + info.assets)
                self.isFetchSubject.onNext(false)
                
                if let next = info.next {
                    self.cursor = next
                } else {
                    self.shouldLoadMore = false
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: Init Methods
    
    init(_ service: OpenSeaService = OpenSeaService()) {
        self.service = service
        
        fetchNextSubject = .init()
        selectedAssetSubject = .init()
        isFetchSubject = .init(value: false)
        assetsSubject = .init(value: [])
        
        input = Input(fetchNext: fetchNextSubject.asObserver(),
                      selectedAsset: selectedAssetSubject.asObserver())
        output = Output(isFetching: isFetchSubject.asDriver(onErrorJustReturn: false),
                        assets: assetsSubject.asDriver(onErrorJustReturn: []),
                        didSelectedAsset: selectedAssetSubject.asSignal(onErrorSignalWith: .never()))
        
        binding()
    }
}
