# GOMS iOS V3

<img width="2558" height="1495" alt="image" src="https://github.com/user-attachments/assets/3f9959a8-0555-47f9-81d2-b4b57b28a836" />

---

## 🤔 GOMS?

**GOMS**는 __광주소프트웨어마이스터고등학교__ Haribo가 개발한 iOS 애플리케이션으로,  
월요일과 수요일에 시행되는 외출제를 **보다 효율적이고 체계적으로 관리하기 위해 제작되었습니다.**

기존 수기 기반 관리 방식에서 발생하던 비효율적인 프로세스를 개선하고,  
외출 현황을 실시간으로 관리할 수 있는 시스템을 구축하는 것을 목표로 합니다.

---

## 🎯 Problem

기존 외출제 운영 과정에서는 다음과 같은 문제가 존재했습니다.

- 학생회가 외출 학생을 수기로 직접 기록해야 하는 구조
- 지각 및 미복귀 학생을 즉시 파악하기 어려운 환경
- 데이터가 체계적으로 관리되지 않아 운영 효율성이 낮은 문제

---

## 💡 Solution

GOMS는 위 문제를 해결하기 위해 다음과 같은 방식으로 설계되었습니다.

- 외출 상태를 실시간으로 **조회할 수 있도록 시스템화**
- 지각 및 미복귀 학생을 **자동으로 식별하는 구조 설계**
- QR 기반 인증 시스템을 도입하여 **출입 관리 정확도 향상**
- 지도 기반 기능을 통해 외출 **시간 활용도를 높이는 사용자 경험 제공**

---

## ✨ Key Features

- 실시간 외출 현황 조회 기능
- 지각 학생 TOP 3 자동 집계 기능
- 7시 30분 기준 미복귀 학생 자동 블랙리스트 등록
- QR 코드 생성 및 스캔 기능
- 학생 검색 및 권한 관리 기능
- 유효하지 않은 QR 코드 차단
- 외출제 상태 푸시 알림
- Kakao Maps SDK 기반 주변 장소 탐색 및 경로 안내

---

## Architecture

- MVVM + Combine  
  View와 비즈니스 로직을 분리하여 유지보수성과 확장성을 확보

- Tuist 기반 모듈화 구조  
  Feature, ThirdPartyLib 단위로 모듈을 분리하여 의존성 관리 및 빌드 효율 개선

---

## 🛠 Tech Stack

### iOS
- UIKit

### Architecture
- MVVM
- Combine

### Project Structure
- Tuist (Modular Architecture)

### Networking
- Moya

### Location
- Kakao Maps SDK
- CoreLocation

### UI
- SnapKit
- Then

### Image
- Kingfisher

### Dependency Management
- Swift Package Manager (SPM)

---

## What Makes This Project Different

- 단순 기능 구현이 아닌 실제 사용자 환경에서 발생한 문제를 기반으로 설계된 서비스
- Tuist를 활용한 모듈화 아키텍처 적용으로 확장성과 유지보수성 확보
- Kakao Maps SDK를 활용한 위치 기반 기능 확장
- 실제 학교 환경에서 사용 가능한 수준의 서비스 완성도

---

## Summary

수기 기반 외출제 관리 방식을 데이터 기반 시스템으로 전환하여  
운영 효율성과 사용자 경험을 동시에 개선한 iOS 애플리케이션

