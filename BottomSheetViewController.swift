//
//  BottomSheetViewController.swift
//
//
//  Created by gaeng2 on 2022/06/17.
//

import UIKit

class BottomSheetViewController: UIViewController {
    var safeAreaHeight: CGFloat!
    var bottomPadding: CGFloat!
    /// 내가 원하는 기본 높이
    var defaultHeight: CGFloat = 200
    
    let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        return view
    }()
    
    let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray30
        
        // 좌측 상단과 좌측 하단의 cornerRadius를 원하는 값으로 설정한다.
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    var bottomSheetViewTopConstraint: NSLayoutConstraint!
    // bottomSheetView에서 키보드를 사용하게 되는 경우 bottomConstraint도 올라가야하기 때문에 선언
    var bottomSheetViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle ♻️
    override func viewDidLoad() {
        self.safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        self.bottomPadding = view.safeAreaInsets.bottom
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    func setupUI() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        
        setupLayout()
    }
    
    func setupLayout() {
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        [dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
         dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)].forEach {
            $0.isActive = true
        }
        
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        let topConstant = view.safeAreaInsets.bottom + view.safeAreaLayoutGuide.layoutFrame.height
        bottomSheetViewTopConstraint = bottomSheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstant)
        bottomSheetViewBottomConstraint = bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        [bottomSheetViewTopConstraint,
         bottomSheetView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         bottomSheetView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
         bottomSheetViewBottomConstraint].forEach {
            $0.isActive = true
        }
    }
    
    func showBottomSheet() {
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom
        
        bottomSheetViewTopConstraint.constant = (safeAreaHeight + bottomPadding) - defaultHeight
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedView.alpha = 0.7
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideBottomSheetAndGoBack(completion: (() -> Void)? = nil) {
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        bottomSheetViewTopConstraint.constant = safeAreaHeight + bottomPadding
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedView.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
                // 다 내려오고 어떤 행동을 할 것인가에 대한 callback 파라미터
                completion?()
            }
        }
    }
    
    // GestureRecognizer 세팅 작업
    private func setupGestureRecognizer() {
        // 흐린 부분 탭할 때, 바텀시트를 내리는 TapGesture
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(_:)))
        dimmedView.addGestureRecognizer(dimmedTap)
        dimmedView.isUserInteractionEnabled = true
        
        // 스와이프 했을 때, 바텀시트를 내리는 swipeGesture
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(panGesture))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    
    
    // UITapGestureRecognizer 연결 함수 부분
    @objc private func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    
    // UISwipeGestureRecognizer 연결 함수 부분
    @objc func panGesture(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .ended {
            switch recognizer.direction {
                case .down:
                    hideBottomSheetAndGoBack()
                default:
                    break
            }
        }
    }
}

