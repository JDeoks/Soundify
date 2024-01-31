//
//  OnboardingViewController.swift
//  Soundify
//
//  Created by JDeoks on 1/31/24.
//

import UIKit
import RxSwift
import RxRelay

class OnboardingViewController: UIViewController {
    
    let onboardingDatas =  [
        ["Simple Converter",
         "with no subscription",
         "",
         "OnboardingImage1"
        ],
        ["",
         "",
         "Select a video from your album.",
         "OnboardingImage2"
        ],
        ["",
         "",
         "Export to Voice Memos.",
         "OnboardingImage3"
        ],
        ["",
         "",
         "If the app is not working,\ncheck your iPhone's settings.",
         "OnboardingImage4"
        ]
    ]
    
    let currentPageIndex = BehaviorRelay<Int>(value: 0)
    let disposeBag = DisposeBag()
    
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var onboardingCollectionView: UICollectionView!
    @IBOutlet var onboardingPageControl: UIPageControl!
    @IBOutlet var goNextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
        action()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let flowLayout = onboardingCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        // 현재 뷰의 크기에 맞게 셀 크기 조정
        flowLayout.itemSize = onboardingCollectionView.bounds.size
        // 레이아웃을 무효화하고 갱신
        flowLayout.invalidateLayout()
        // 레이아웃 변경사항즉시 업데이트
        onboardingCollectionView.layoutIfNeeded()
    }
    
    func initUI() {
        // skipButton
        let attributedString = NSMutableAttributedString(string: skipButton.titleLabel?.text ?? "")
        attributedString.addAttribute(
            NSAttributedString.Key.underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributedString.length)
        )
        let font = UIFont.systemFont(ofSize: 16)
        attributedString.addAttribute(
            NSAttributedString.Key.font,
            value: font,
            range: NSRange(location: 0, length: attributedString.length)
        )
        skipButton.setAttributedTitle(attributedString, for: .normal)
        
        // onboardingCollectionView
        onboardingCollectionView.dataSource = self
        onboardingCollectionView.delegate = self
        let onboardingCollectionViewCell = UINib(nibName: "OnboardingCollectionViewCell", bundle: nil)
        onboardingCollectionView.register(onboardingCollectionViewCell, forCellWithReuseIdentifier: "OnboardingCollectionViewCell")
        let onboardingFlowLayout = UICollectionViewFlowLayout()
        onboardingFlowLayout.scrollDirection = .horizontal
        onboardingCollectionView.collectionViewLayout = onboardingFlowLayout
        onboardingCollectionView.isPagingEnabled = true
        
        // onboardingPageControl
        onboardingPageControl.currentPageIndicatorTintColor = ColorManager.shared.keyboardToolBarButton
        onboardingPageControl.pageIndicatorTintColor = ColorManager.shared.keyboardToolBar

        // goNextButton
        goNextButton.layer.cornerRadius = 8
        goNextButton.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .thin)
    }
    
    func initData() {
        // onboardingPageControl
        onboardingPageControl.numberOfPages = onboardingDatas.count
    }
    
    func action() {
        skipButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        goNextButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                // 시작 버튼 클릭
                let endIdx = self.onboardingDatas.count - 1
                if self.currentPageIndex.value < endIdx {
                    self.currentPageIndex.accept(self.currentPageIndex.value + 1)
                } else {
                    self.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        onboardingPageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
    }
    
    @objc func pageControlChanged(_ sender: UIPageControl) {
        currentPageIndex.accept(sender.currentPage)
    }
    
    func bind() {
        currentPageIndex
            .subscribe { newPageIndex in
                self.pageIndexChanged(newPageIndex: newPageIndex)
            }
            .disposed(by: disposeBag)
    }
    
    func pageIndexChanged(newPageIndex idx: Int) {
        print("\(type(of: self)) - \(#function)", idx)

        // onboardingPageControl
        onboardingPageControl.currentPage = idx
        // onboardingCollectionView
        let indexPath = IndexPath(item: idx, section: 0)
        onboardingCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // nextButton
        let endIdx = self.onboardingDatas.count - 1
        if idx == endIdx {
            goNextButton.setTitle("Start", for: .normal)
        } else {
            goNextButton.setTitle("Next", for: .normal)
        }
        goNextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21)
    }

}

// MARK: - UICollectionView, UIScrollView
extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = onboardingCollectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnboardingCollectionViewCell
        let idx = indexPath.row
        
        // onboardingtitleLabel
        if onboardingDatas[idx][0].isEmpty {
            cell.onboardingtitleLabel.isHidden = true
        } else {
            cell.onboardingtitleLabel.isHidden = false
            cell.onboardingtitleLabel.text = onboardingDatas[idx][0]
        }
        
        // onBoardingsubTitleLabel
        if onboardingDatas[idx][1].isEmpty {
            cell.onBoardingsubTitleLabel.isHidden = true
        } else {
            cell.onBoardingsubTitleLabel.isHidden = false
            cell.onBoardingsubTitleLabel.text = onboardingDatas[idx][1]
        }
        
        // onboardingDescLabel
        if onboardingDatas[idx][2].isEmpty {
            cell.onboardingDescLabel.isHidden = true
        } else {
            cell.onboardingDescLabel.isHidden = false
            cell.onboardingDescLabel.text = onboardingDatas[idx][2]
        }
        cell.layoutIfNeeded()
        
        // onboardingImageView
        cell.onboardingImageView.image = UIImage(named: onboardingDatas[indexPath.row][3])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let newIndex = Int(scrollView.contentOffset.x / width)
        if currentPageIndex.value != newIndex {
            currentPageIndex.accept(newIndex)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 섹션 간의 수직 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // 섹션 내 아이템 간의 수평 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

