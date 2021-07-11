//
//  CourseAPI.swift
//  Journey
//
//  Created by 초이 on 2021/07/11.
//

import Foundation
import Moya

public class CourseAPI {
    
    static let shared = CourseAPI()
    var challengeProvider = MoyaProvider<CourseService>()
    
    public init() { }
    
    func getCourseLibrary(completion: @escaping (NetworkResult<Any>) -> Void) {
        challengeProvider.request(.getCourseLibrary) { (result) in
            
            switch result {
            case.success(let response):
                
                let statusCode = response.statusCode
                let data = response.data
                
                let networkResult = self.judgeStatus(by: statusCode, data)
                completion(networkResult)
                
            case .failure(let err):
                print(err)
            }
            
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case 200:
            return isValidData(data: data)
        case 400..<500:
            return .pathErr
        case 500:
            return .serverErr
        default:
            return .networkFail
        }
    }
    
    private func isValidData(data: Data) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        
        let decodedData = try! decoder.decode(CoursesResponseData.self, from: data)
        print(decodedData)
        
//        guard let decodedData = try? decoder.decode(CourseResponseData.self, from: data) else {
//            return .pathErr
//        }
        
        return .success(decodedData.data)
    }
}
