//
//  LetecomerViewModel.swift
//  Feature
//
//  Created by 김민선 on 4/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya
import Service

struct LatecomerListData {
    let id: Int
    let profileImageURL: String?
    let name: String
    let grade: Int
    let department: String
}

public final class LetecomerViewModel: BaseViewModel {
    
    private let studentCouncilProvider = MoyaProvider<StudentCouncilServices>()
    
    var date: String = {
        let currentDate = Date()
        let lastWednesday = currentDate.lastWednesday()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: lastWednesday)
    }()
    
    var latecomerList: [LatecomerListResponse] = []
    var latecomerListDatas: [LatecomerListData] = []
    
    func setupDate(date: String) {
        self.date = date
    }
    
    func getLatecomerList(completion: @escaping ([LatecomerListData]) -> Void) {
        studentCouncilProvider.request(.lateList(authorization: accessToken, date: date)) { response in
            switch response {
            case .success(let result):
                let responseData = result.data
                do {
                    let decodedResponse = try JSONDecoder().decode(LatecomerListWrappedResponse.self, from: responseData)
                    self.latecomerList = decodedResponse.students
                    
                    self.latecomerListDatas = self.latecomerList.map {
                        LatecomerListData(
                            id: $0.memberId,
                            profileImageURL: $0.profileImageUrl,
                            name: $0.name,
                            grade: $0.grade,
                            department: $0.department
                        )
                    }
                    DispatchQueue.main.async {
                        completion(self.latecomerListDatas)
                    }
                } catch(let err) {
                    print("Latecomer decode error: \(err)")
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}

struct LatecomerListWrappedResponse: Decodable {
    let students: [LatecomerListResponse]
}

struct LatecomerListResponse: Decodable {
    let memberId: Int
    let name: String
    let grade: Int
    let department: String
    let profileImageUrl: String?
}
