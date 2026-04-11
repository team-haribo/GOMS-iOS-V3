//
//  StudentManagementViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya
import Service

public struct UserData {
    let id: Int
    let name: String
    let profileImageURL: String?
    let grade: Int
    let major: String
    let authority: String
    let isBlackList: Bool
    let isOuting: Bool
}

public final class StudentManagementViewModel: BaseViewModel {
    private let studentCouncilProvider = MoyaProvider<StudentCouncilServices>()
    
    var userList: [Service.Student] = []
    var userListDatas: [UserData] = []
    
    private var grade: Int?
    private var gender: String?
    private var isBlackList: Bool?
    private var isOuting: Bool?
    private var authority: String?
    private var major: String?
    
    func setupGrade(grade: Int?) { self.grade = grade }
    func setupGender(gender: String?) { self.gender = gender }
    func setupIsOuting(isOuting: Bool?) { self.isOuting = isOuting }
    func setupIsBlackList(isBlackList: Bool?) { self.isBlackList = isBlackList }
    func setupAuthority(authority: String?) { self.authority = authority }
    func setupMajor(major: String?) { self.major = major }
    
    func resetInfo() {
        self.grade = nil; self.gender = nil; self.isBlackList = nil
        self.authority = nil; self.major = nil; self.isOuting = nil
    }
    
    private func mapToUserData() {
        self.userListDatas = self.userList.map {
            UserData(
                id: $0.memberId,
                name: $0.name,
                profileImageURL: $0.profileImageUrl,
                grade: $0.grade,
                major: $0.department,
                authority: $0.role,
                isBlackList: $0.status == "CANNOT_OUTING",
                isOuting: $0.status == "OUTING"
            )
        }
    }
    
    func getUserList(completion: @escaping () -> Void) {
        studentCouncilProvider.request(.studentList(authorization: accessToken)) { response in
            if case let .success(result) = response, result.statusCode == 200 {
                do {
                    self.userList = try JSONDecoder().decode(StudentListModel.self, from: result.data).students
                    self.mapToUserData()
                    completion()
                } catch { print(error) }
            } else if case let .success(result) = response, result.statusCode == 401 {
                self.gomsRefreshToken.tokenReissuance { _ in }
            }
        }
    }
    
    func changeAuthority(user: UserData, completion: @escaping () -> Void) {
        let newRole: Authority = user.authority == Authority.student.rawValue ? .admin : .student
        let body = AuthorityRequest(role: newRole.rawValue)

        studentCouncilProvider.request(.editAuthority(authorization: accessToken, memberId: user.id, param: body)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func blackList(user: UserData, completion: @escaping () -> Void) {
        let body = OutingAllowedRequest(status: .cannotOuting)

        studentCouncilProvider.request(.outingAllowed(authorization: accessToken, memberId: user.id, param: body)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func cancelBlackList(user: UserData, completion: @escaping () -> Void) {
        let body = OutingAllowedRequest(status: .coming)

        studentCouncilProvider.request(.outingAllowed(authorization: accessToken, memberId: user.id, param: body)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    func forceOutingStudent(user: UserData, completion: @escaping () -> Void) {
        studentCouncilProvider.request(.forceOuting(authorization: accessToken, memberId: user.id)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    completion()
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    func searchStudent(searchString: String?, completion: @escaping () -> Void) {
        guard let name = searchString, !name.isEmpty else {
            getUserList(completion: completion)
            return
        }
        
        let param = SearchStudentRequest(
            grade: nil,
            gender: nil,
            name: name,
            isBlackList: nil,
            authority: nil,
            major: nil
        )
        studentCouncilProvider.request(.searchStudent(authorization: accessToken, param: param)) { response in
            switch response {
            case .success(let result):
                if result.statusCode == 200 {
                    do {
                        self.userList = try JSONDecoder().decode(StudentListModel.self, from: result.data).students
                        self.mapToUserData()
                        completion()
                    } catch {
                        print(error)
                    }
                } else if result.statusCode == 401 {
                    self.gomsRefreshToken.tokenReissuance { _ in }
                } else {
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
