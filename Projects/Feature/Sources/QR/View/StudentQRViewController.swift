//
//  StudentQRViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

public class StudentQRViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {

    override func shouldShowCustomNavigation() -> Bool {
        return false
    }

    let viewModel = QRCodeViewModel()

    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?

    let metadataObjectTypes: [AVMetadataObject.ObjectType] = [.qr]

    private var isScanningEnabled = true
    private var lastUsedUUID: String?
    private var lastScanTime = Date(timeIntervalSince1970: 0)
    private let scanInterval: TimeInterval = 0.3

    private let gomsLogo = UIImageView().then {
        $0.image = .image.gomsWhiteLogo.image
    }

    private lazy var closeButton = UIButton().then {
        $0.setImage(.image.gomsCloseButton.image, for: .normal)
        $0.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    }

    private let qrFrame = UIImageView().then {
        $0.image = .image.qr.image
    }

    // MARK: - Life Cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setLayout()
        setupCamera()
    }

    // MARK: - Selector
    @objc func closeButtonDidTap() {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    // MARK: - Add View
    public override func addView() {
        [closeButton, qrFrame].forEach { self.view.addSubview($0) }
    }

    // MARK: - Layout
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    public override func setLayout() {

        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        qrFrame.snp.makeConstraints {
            $0.width.height.equalTo(bounds.width * 0.64)
            $0.centerY.centerX.equalToSuperview()
        }
    }

    func qrScanResult(result: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isScanningEnabled = true
        }

        if result == "comeback" {
            let vc = QRResultViewController(resultType: .comeback)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if result == "outing" {
            let vc = QRResultViewController(resultType: .outing)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if result == "blackList" {
            let vc = QRResultViewController(resultType: .blacklist)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if result == "uuidError" {
            let vc = QRResultViewController(resultType: .qrError)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    public func setupCamera() {
        guard let camera = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
        } catch {
            print(error.localizedDescription)
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0)
        }

        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
}
extension StudentQRViewController {

    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                              didOutput metadataObjects: [AVMetadataObject],
                              from connection: AVCaptureConnection) {

        let now = Date()
        guard now.timeIntervalSince(lastScanTime) > scanInterval else { return }
        lastScanTime = now

        guard isScanningEnabled,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let payload = metadataObject.stringValue else { return }

        print("QR detected:", payload)

        isScanningEnabled = false

  
        guard let data = payload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let uuidString = json["uuid"] as? String,
              let exp = json["exp"] as? Int,
              let uuid = UUID(uuidString: uuidString) else {
            
            print("QR 파싱 실패")
            isScanningEnabled = true
            return
        }

        if uuidString == lastUsedUUID {
            print("같은 QR 사용 불가 (외출/복귀 동일 QR 방지)")
            self.qrScanResult(result: "uuidError")
            isScanningEnabled = true
            return
        }

        let expSec = exp > 10000000000 ? exp / 1000 : exp
        let nowSec = Int(Date().timeIntervalSince1970)

        if expSec < nowSec {
            print("QR 만료됨")
            self.qrScanResult(result: "uuidError")
            isScanningEnabled = true
            return
        }

        viewModel.outingUUID = uuid
        lastUsedUUID = uuidString
        viewModel.exp = expSec

        viewModel.outing { result in
            DispatchQueue.main.async {
                self.captureSession.stopRunning()
                self.qrScanResult(result: result)
            }
        }
    }
}
