//
//  AssetViewController.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import Kingfisher
import RxSwift
import RxCocoa
import UIKit

class AssetViewController: UIViewController {
    private lazy var imageView: UIImageView = {
        imageViewHeightConstraint = $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 1)
        
        $0.addConstraints([
            $0.widthAnchor.constraint(equalToConstant: prefferedImageViewWidth),
            imageViewHeightConstraint!
        ])
        return $0
    }(UIImageView())
    
    private lazy var nameLabel: UILabel = {
        return $0
    }(UILabel())
    
    private lazy var descLabel: UILabel = {
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.required, for: .vertical)
        return $0
    }(UILabel())
    
    private lazy var linkBtn: UIButton = {
        $0.setTitle("Permalink", for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.layer.borderColor = UIColor.darkGray.cgColor
        $0.layer.borderWidth = 1
        return $0
    }(UIButton())
    
    private lazy var stackView: UIStackView = {
        let subviews = [imageView, nameLabel, descLabel]
        let view = UIStackView(arrangedSubviews: subviews)
        view.spacing = 20
        view.axis = .vertical
        view.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        return $0
    }(UIScrollView())
    
    let viewModel: AssetViewModel
    
    private var disposeBag = DisposeBag()
    private var imageViewHeightConstraint: NSLayoutConstraint?
    private let prefferedImageViewWidth = UIScreen.main.bounds.size.width - (20 * 2)
    
    // MARK: Private Methods
    
    private func setupStyle() {
        view.backgroundColor = .white
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        linkBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(linkBtn)
        
        NSLayoutConstraint.activate([
            linkBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            linkBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            linkBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            linkBtn.heightAnchor.constraint(equalToConstant: 40),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: linkBtn.topAnchor, constant: -10),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    private func binding() {
        let observable = viewModel.output.asset.asObservable().share(replay: 1, scope: .whileConnected)
        
        observable.map { $0.collection?.name }
        .bind(to: navigationItem.rx.title)
        .disposed(by: disposeBag)
        
        observable.map { $0.name }
        .bind(to: nameLabel.rx.text)
        .disposed(by: disposeBag)
        
        observable.map { $0.description }
        .bind(to: descLabel.rx.text)
        .disposed(by: disposeBag)
        
        observable.map { $0.image_url }
        .do(onNext: { [weak self] image_url in
            guard let self = self else { return }
            
            let url = try? image_url?.asURL()
            self.imageView.kf.setImage(with: url) { [weak self] result in
                guard let self = self else { return }
                
                if case let .success(info) = result, let heightConstraint = self.imageViewHeightConstraint {
                    let ratio = info.image.size.height / info.image.size.width
                    let height = self.prefferedImageViewWidth * ratio
                    heightConstraint.constant = height - self.prefferedImageViewWidth
                }
            }
        })
        .subscribe()
        .disposed(by: disposeBag)
            
        observable.map { ($0.permalink == nil) ? false : true }
        .bind(to: linkBtn.rx.isEnabled)
        .disposed(by: disposeBag)
            
        linkBtn.rx.tap
        .bind(to: viewModel.input.openLink)
        .disposed(by: disposeBag)
    }
    
    // MARK: Init Methods
    
    init(_ viewModel: AssetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupStyle()
        setupLayout()
        binding()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewModel.input.finish.onNext(())
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
