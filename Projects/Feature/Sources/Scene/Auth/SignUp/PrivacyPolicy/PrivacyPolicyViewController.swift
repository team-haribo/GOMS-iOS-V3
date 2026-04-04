//
//  PrivacyPolicyViewController.swift
//  Feature
//
//  Created by 김민선 on 4/4/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

final class PrivacyPolicyViewController: UIViewController {
    
    var onAgreeCompletion: (() -> Void)?
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "개인정보 처리방침"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .white
    }
    
    private let backButton = UIButton().then {
        $0.setTitle("< 돌아가기", for: .normal)
        $0.setTitleColor(.orange, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    private let textView = UITextView().then {
        $0.text = """
        1. 개인정보 수집 항목 및 방법
        Goms는 회원가입, 서비스 이용 등을 위해 아래와 같은 개인정보를 수집하고 있습니다.
        [수집항목]
        - 회원 가입시 필수 항목: 이메일, 비밀번호
        - 선택 항목: 없음
        - 서비스 이용과정에서 아래와 같은 정보들이 자동으로 생성되어 수집될 수 있습니다: IP 주소, 쿠키, 접속 브라우저, 서비스 이용기록, 회원조치이력
        [개인정보 수집방법]
        - 회원가입, 회원정보 수정

        2. 개인정보의 수집 및 이용 목적
        Goms는 수집한 개인정보를 다음의 목적을 위해 활용하며 다른 용도로는 사용되지 않습니다. 차후 이용목적이 변경될 시에는 사전에 동의를 구합니다.
        - 이메일, 비밀번호: 서비스 이용에 따른 본인식별, 중복가입 확인, 부정이용 방지
        - 이메일: 전체메일발송, 패스워드 분실시 필요한 정보제공 및 민원처리
        - 그 외 선택 사항: 개인 맞춤 서비스를 제공하기 위해 사용됩니다.

        3. 개인정보의 보유 및 이용기간
        Goms는 회원가입일로부터 서비스를 제공하는 기간 동안에 한하여 이용자의 개인정보를 보유 및 이용합니다.

        4. 개인정보의 파기절차 및 방법
        원칙적으로 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체없이 파기합니다.
        [파기절차]
        회원이 입력하신 정보는 목적 달성 후 내부 방침 및 관련 법령에 따라 일정 기간 저장된 후 파기됩니다. 법령에 의한 경우를 제외하고는 보유 목적 이외의 다른 목적으로 이용되지 않습니다.
        [파기방법]
        전자적 파일형태로 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제합니다.

        5. 개인정보 제공
        Goms는 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. 다만, 이용자가 사전에 동의하거나 법령의 규정에 의거한 경우, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우는 예외로 합니다.

        6. 수집한 개인정보의 위탁
        Goms는 회원 정보를 외부 업체에 위탁하지 않습니다.

        7. 회원 및 법정대리인의 권리와 그 행사방법
        이용자는 언제든지 자신의 개인정보를 조회하거나 수정할 수 있으며 가입해지를 요청할 수도 있습니다. 본인 확인 후 직접 열람, 정정 또는 탈퇴가 가능하며, 개인정보관리책임자에게 서면, 전화 또는 이메일로 연락하시면 지체 없이 조치하겠습니다.

        8. 개인정보 자동수집 장치의 설치, 운영 및 그 거부에 관한 사항
        Goms는 이용자에게 개별적인 맞춤서비스를 제공하기 위해 이용정보를 저장하고 수시로 불러오는 쿠키(cookie)를 사용하지 않습니다.

        9. 개인정보의 기술적, 관리적 보호대책
        Goms는 개인정보가 분실, 도난, 유출, 변조 또는 훼손되지 않도록 다음과 같은 대책을 강구하고 있습니다.
        - 비밀번호 암호화: 중요 정보는 암호화하여 보관합니다.
        - 기술적 대책: 해킹이나 바이러스 방지를 위해 외부 접근 통제 구역에 시스템을 설치하고 24시간 감시하며 백신 프로그램을 운영합니다.
        - 관리 대책: 이용자 본인의 주의도 필요합니다. 아이디와 비밀번호가 유출되지 않도록 각별히 주의해 주시기 바랍니다.

        10. 개인정보에 관한 민원서비스
        이용자는 모든 개인정보보호 관련 민원을 개인정보 관리책임자에게 신고하실 수 있습니다.
        [개인정보관리책임자]
        성명 : 모태환 / 직책 : PM / 연락처 : s24023@gsm.hs.kr
        기타 신고 기관: 개인정보침해신고센터(118), 대검찰청 사이버수사과(1301), 경찰청 사이버안전국(182)

        11. 부칙
        이 개인정보처리방침은 2024년 3월 27일부터 적용되며, 법령, 정책 또는 보안기술의 변경에 따라 내용의 추가, 삭제 및 수정이 있을시에는 변경사항의 시행일의 7일 전부터 전체메일발송을 통하여 고지할 것입니다.
        """
        $0.isEditable = false
        $0.backgroundColor = .clear
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.showsVerticalScrollIndicator = true // 내용이 길어서 스크롤 바 추가!
    }
    
    private let agreeButton = UIButton().then {
        $0.setTitle("개인정보 수집 동의", for: .normal)
        $0.backgroundColor = .orange
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.layer.cornerRadius = 8
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        addView()
        setLayout()
        bindAction()
    }
    
    private func addView() {
        [backButton, titleLabel, textView, agreeButton].forEach { view.addSubview($0) }
    }
    
    private func setLayout() {
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(agreeButton.snp.top).offset(-20)
        }
        
        agreeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(50)
        }
    }
    
    private func bindAction() {
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        agreeButton.addTarget(self, action: #selector(agreeButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func backButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc private func agreeButtonDidTap() {
        // 1. 클로저 실행 (나 동의했어! 라고 신호 보냄)
        onAgreeCompletion?()
        // 2. 화면 닫기
        dismiss(animated: true)
    }
}
