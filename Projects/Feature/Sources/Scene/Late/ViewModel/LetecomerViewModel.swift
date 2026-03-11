//
//  LetecomerViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya
import Service

struct LatecomerListData {
    let id: UUID
    let profileImageURL: String?
    let name: String
    let grade: Int
    let major: String
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
                    self.latecomerList = try JSONDecoder().decode([LatecomerListResponse].self, from: responseData)
                    self.latecomerListDatas = self.latecomerList.map { LatecomerListData(id: $0.accountIdx, profileImageURL: $0.profileUrl, name: $0.name, grade: $0.grade, major: $0.major) }
                    completion(self.latecomerListDatas)
                } catch(let err) {
                    print(String(describing: err))
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
