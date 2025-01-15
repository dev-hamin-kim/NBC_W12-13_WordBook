//
//  WordCardView.swift
//  SwiftRun
//
//  Created by 김하민 on 1/8/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WordCardView: UIView {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let memorizedButton: MemorizedButton = .init()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "asdf123"
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.textColor = .sr900Black
        
        return label
    }()
    
    private let subnameLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "asdf123"
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.textColor = .sr700Gray
        
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.text = "asdf123"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.textColor = .sr900Black
        
        return label
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .sr400Gray
        button.setTitle("이전", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.tintColor = .sr100White
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .srBlue600Primary
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.tintColor = .sr100White
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    // MARK: - UI StackView
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            memorizedButton, nameLabel, subnameLabel, detailsLabel
        ])
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        return stackView
    }()
    
    // MARK: - Initializers
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        addSubview(nextButton)
        addSubview(previousButton)
        
        layer.cornerRadius = 16
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - Function for binding with ViewModel
    
    func bind(to viewModel: WordCardStackViewModel) {
        viewModel.currentCard.observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] word in
                    self?.nameLabel.text = word.name
                    self?.subnameLabel.text = word.subName
                    self?.detailsLabel.text = word.definition
                }
            ).disposed(by: disposeBag)
        
        viewModel.didMemorizeCurrentCard.observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] bool in
                    self?.memorizedButton.updateButton(bool)
                    self?.updateBackground(bool)
                }
            ).disposed(by: disposeBag)
        
        viewModel.isLastCard.observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] bool in
                    self?.nextButton.setTitle(bool ? "완료" : "다음", for: .normal)
                    self?.nextButton.backgroundColor = bool ? .swiftOrange400 : .srBlue600Primary
                }
            ).disposed(by: disposeBag)
        
        memorizedButton.rx.tap
            .subscribe(onNext: { viewModel.memorizedButtonTapped() })
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .subscribe(onNext: { viewModel.previousCard() })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { viewModel.nextCard() })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI functions
    private func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalToSuperview().dividedBy(3)
            make.centerY.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(24)
            make.height.equalTo(40)
            make.width.equalToSuperview().dividedBy(2.5)
        }
        
        previousButton.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(24)
            make.height.equalTo(40)
            make.width.equalToSuperview().dividedBy(2.5)
        }
    }
    
    private func updateBackground(_ didMemorize: Bool) {
         backgroundColor = didMemorize ? .srBlue200 : .sr200Gray
        layer.borderColor = didMemorize ? UIColor.srBlue700.cgColor : UIColor.sr700Gray.cgColor
        layer.borderWidth = 3.0
    }
}
