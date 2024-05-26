//
//  OrdersDetailsModel.swift
//  Hamla_iOS_Captain
//
//  Created by Bassant on 17/05/2024.
//

import Foundation

// MARK: - Response
struct OrdersDetailsModel: Codable {
    let status: Int
    let message: String
    let data: [Order]?
}

// MARK: - Order
struct Order: Codable {
    var id: Int?
    var code: String?
    var status: String?
    var statusTitle: String?
    var cost: String?
    var estimateTime: String?
    var dropoffLocationName: String?
    var dropoffLat: String?
    var dropoffLng: String?
    var pickupLocationName: String?
    var pickupLat: String?
    var pickupLng: String?
    var paymentMethod: PaymentMethod?
    var customer: Customer?
    var pickType: String?
    var truckType: String?
    var weight: String?
    var pickAmount: String?
    var type: String?
    var date: String?
    var estimateCostFrom: String?
    var estimateCostTo: String?

    // Coding keys to match the JSON keys with Swift property names
    enum CodingKeys: String, CodingKey {
        case id, code, status
        case statusTitle = "status_title"
        case cost
        case estimateTime = "estimate_time"
        case dropoffLocationName = "dropoff_location_name"
        case dropoffLat = "dropoff_lat"
        case dropoffLng = "dropoff_lng"
        case pickupLocationName = "pickup_location_name"
        case pickupLat = "pickup_lat"
        case pickupLng = "pickup_lng"
        case paymentMethod = "payment_method"
        case customer
        case pickType = "pick_type"
        case truckType = "truck_type"
        case weight
        case pickAmount = "pick_amount"
        case type, date
        case estimateCostFrom = "estimate_cost_from"
        case estimateCostTo = "estimate_cost_to"
    }
}

struct PaymentMethod: Codable {
    let id: Int?
    let name: String?
    let type: String?
    let icon: String?
}

// MARK: - Customer
struct Customer: Codable {
    let id: Int?
    let fullName: String?
    let mobile: String?
    let code: String?
    let rate: Int?
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case mobile, code, rate, avatar
    }
}
