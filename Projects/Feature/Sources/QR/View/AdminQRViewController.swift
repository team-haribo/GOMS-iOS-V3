//
//  AdminQRViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import UIKit
import QRCode
import CoreImage

public class AdminQRViewController: BaseViewController {
    

    public override func configNavigation() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: Propertices
    let viewModel = QRCodeViewModel()
    
    private var timer: Int = 300
    
    private let titleText = UILabel().then {
        $0.text = "외출 QR코드"
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 24, weight: .bold)
    }
    
    private lazy var backButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(UIColor.color.admin.color, for: .normal)
        $0.tintColor = UIColor.color.admin.color
        $0.titleLabel?.font = .suit(size: 16, weight: .medium)
        $0.addTarget(self, action: #selector(qrExitButtonTapped), for: .touchUpInside)
    }
    
    @objc func qrExitButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private let qrCodeImage = UIImageView()
    
    private let lastTimeText = UILabel().then {
        $0.text = "QR코드 만료까지"
        $0.textColor = .color.gomsSecondary.color
        $0.font = UIFont.suit(size: 15, weight: .medium)
    }
    
    private var lastTimer = UILabel().then {
        $0.text = "5분 00초"
        $0.textColor = .color.admin.color
        $0.font = UIFont.suit(size: 20, weight: .semibold)
    }
    
    // MARK: Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        createQRCode()
    }

    public override func shouldShowCustomNavigation() -> Bool {
            return false
        }
    
    // MARK: Add View
    public override func addView() {
        [backButton, titleText, qrCodeImage, lastTimeText, lastTimer].forEach { view.addSubview($0) }
    }
    
    // MARK: Layout
    public override func setLayout() {
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleText.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        qrCodeImage.snp.makeConstraints {
            $0.top.equalTo(titleText.snp.bottom).offset(124)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(200)
        }
        
        lastTimeText.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.top.equalTo(qrCodeImage.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }

        lastTimer.snp.makeConstraints {
            $0.top.equalTo(lastTimeText.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (t) in
            guard let self = self else { return }
            self.timer -= 1
            let minutes = self.timer / 60
            let seconds = self.timer % 60
            if self.timer > 0 {
                self.lastTimer.text = String(format: "%d분 %02d초", minutes, seconds)
            }
            else {
                self.lastTimer.text = "0분 00초"
                self.timer = 300
                self.createQRCode()
            }
        })
    }
    
    private func createQRCode() {
        viewModel.makeQR { [weak self] success in
            guard let self = self else { return }
            
            if success {
                
                let qrData: [String: Any] = [
                    "uuid": self.viewModel.outingUUID.uuidString,
                    "exp": self.viewModel.exp
                ]

                guard let jsonData = try? JSONSerialization.data(withJSONObject: qrData),
                      let jsonString = String(data: jsonData, encoding: .utf8) else {
                    print("QR JSON 생성 실패")
                    return
                }

                if self.viewModel.exp > 0 {
                    let currentTimeDebug = Int(Date().timeIntervalSince1970 * 1000)
                    let remaining = (self.viewModel.exp - currentTimeDebug) / 1000
                    self.timer = max(remaining, 0)
                }

                if let qrCodeImage = self.generateQRCode(from: jsonString) {
                    DispatchQueue.main.async {
                        self.qrCodeImage.image = qrCodeImage
                    }
                } else {
                    print("Failed to generate QR code.")
                }
            }
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let qrFilter = CIFilter.qrCodeGenerator()
        qrFilter.setValue(data, forKey: "inputMessage")
        
        guard let qrCodeCIImage = qrFilter.outputImage else { return nil }
        
        let scaleX = qrCodeImage.frame.width / qrCodeCIImage.extent.width
        let scaleY = qrCodeImage.frame.height / qrCodeCIImage.extent.height
        let transformedImage = qrCodeCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        return UIImage(ciImage: transformedImage)
    }
}
