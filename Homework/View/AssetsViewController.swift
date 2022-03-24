//
//  AssetsViewController.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import UIKit
import RxSwift
import RxCocoa
import KRProgressHUD

class AssetsViewController: ViewController {
    
    private lazy var collectionView: UICollectionView = {
        let screeSize = UIScreen.main.bounds.size
        let width = (screeSize.width - (20 * 3)) / 2
        let height = width + 80
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        view.register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.description())
        view.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return view
    }()
    
    private let viewModel: AssetsViewModel
    
    private var disposeBag = DisposeBag()
    
    // MARK: Private Methods
    
    private func setupStyle() {
        navigationItem.title = "Assets"
        view.backgroundColor = .white
    }
    
    private func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func binding() {
        viewModel.output.isFetching
            .asObservable()
            .do(onNext: { isFetching in
                if isFetching {
                    KRProgressHUD.show(withMessage: "Loading...")
                } else {
                    KRProgressHUD.dismiss(nil)
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.output.assets
            .drive(collectionView.rx
                    .items(cellIdentifier: AssetCell.description(),
                           cellType: AssetCell.self)) { _, info, cell in
                cell.bind(info)
            }.disposed(by: disposeBag)
        
        
        
        collectionView.rx
            .modelSelected(AssetInfo.self)
            .do(onNext: { [weak self] info in
                guard let self = self else { return }
                
                self.viewModel.input.selectedAsset.onNext(info)
            })
            .subscribe()
            .disposed(by: disposeBag)
                
       collectionView.rx
            .didEndDecelerating
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { _ -> Observable<Void> in
                let point = self.collectionView.contentOffset
                let shouldLoadMore = self.collectionView.contentSize.height - point.y < self.collectionView.bounds.height
                return (shouldLoadMore) ? .just(()) : .never()
            }
            .bind(to: viewModel.input.fetchNext)
            .disposed(by: disposeBag)
    }
    
    // MARK: Init Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupLayout()
        binding()
        
        viewModel.input.fetchNext.onNext(()) 
    }
    
    init(_ viewModel: AssetsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
