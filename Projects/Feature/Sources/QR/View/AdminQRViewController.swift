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
    
    // MARK: Propertices
    let viewModel = QRCodeViewModel()
    
    private var timer: Int = 300
    
    private let titleText = UILabel().then {
        $0.text = "외출 QR코드"
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 29, weight: .bold)
    }
    
    @objc func qrExitButtonTapped() {
        let adminMainVC = AdminMainViewController()
        self.navigationController?.pushViewController(adminMainVC, animated: true)
    }
    
    private let qrCodeImage = UIImageView()
    
    private let lastTimeText = UILabel().then {
        $0.text = "QR코드 만료까지"
        $0.textColor = .color.gomsSecondary.color
        $0.font = UIFont.suit(size: 14, weight: .regular)
    }
    
    private var lastTimer = UILabel().then {
        $0.text = "5분 00초"
        $0.textColor = .color.admin.color
        $0.font = UIFont.suit(size: 19, weight: .semibold)
    }
    
    // MARK: Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        createQRCode()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isHidden = false
    }
    

    
    // MARK: Add View
    public override func addView() {
        [titleText, qrCodeImage, lastTimeText, lastTimer].forEach { view.addSubview($0) }
    }
    
    // MARK: Layout
    public override func setLayout() {
        titleText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
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
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) in
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
        viewModel.makeQR { success in
            if success {
                let outingUUIDString = self.viewModel.outingUUID.uuidString
                if let qrCodeImage = self.generateQRCode(from: outingUUIDString) {
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
