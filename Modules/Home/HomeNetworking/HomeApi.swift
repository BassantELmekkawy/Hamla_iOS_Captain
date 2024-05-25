//
//  HomeApi.swift
//  Hamla_iOS_Captain
//
//  Created by Bassant on 21/04/2024.
//

import Foundation

protocol HomeApiProtocol {
    
    func getCaptainDetails(completion: @escaping (Result<RegisterModel? , CustomError>) -> Void)
    func getOrdersDetails(orderIDs: [String], completion: @escaping (Result<OrdersDetailsModel? , CustomError>) -> Void)
    func acceptOrder(orderID: String, captainLat: String, captainLng: String, completion: @escaping (Result<Model? , CustomError>) -> Void)
    func updateAvailability(lat: String, lng: String, completion: @escaping (Result<UpdateAvailabilityModel? , CustomError>) -> Void)
}

class HomeApi: BaseAPI<HomeNetworking>,HomeApiProtocol{
    func updateAvailability(lat: String, lng: String, completion: @escaping (Result<UpdateAvailabilityModel?, CustomError>) -> Void) {
        self.performRequest(target: .updateAvailability(lat: lat, lng: lng), responseClass: UpdateAvailabilityModel.self) { result in
            print("result", result)
            completion(result)
        }
    }
    
    
    func getCaptainDetails(completion: @escaping (Result<RegisterModel?, CustomError>) -> Void) {
        self.performRequest(target: .captainDetails, responseClass: RegisterModel.self) { result in
            print("result", result)
            completion(result)
        }
    }
    
    func getOrdersDetails(orderIDs: [String], completion: @escaping (Result<OrdersDetailsModel?, CustomError>) -> Void) {
        self.performRequest(target: .getOrdersDetails(orderIDs: orderIDs), responseClass: OrdersDetailsModel.self) { result in
            print("result", result)
            completion(result)
        }
    }
    
    func acceptOrder(orderID: String, captainLat: String, captainLng: String, completion: @escaping (Result<Model? , CustomError>) -> Void) {
        self.performRequest(target: .acceptOrder(orderID: orderID, captainLat: captainLat, captainLng: captainLng), responseClass: Model.self) { result in
            print("result", result)
            completion(result)
        }
    }
    
}
