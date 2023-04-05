//
//  InsuranceLists.swift
//
//  Created by Cuong.tran on 04/08/2022.

import Foundation

// MARK: - InsuranceLists
struct InsuranceLists: Codable {
    var total: Int?
    var insurances: [Insurance]?
    
    enum CodingKeys: String, CodingKey {
        case insurances = "insurance"
        case total = "total"
    }
}

// MARK: InsuranceLists convenience initializers and mutators

extension InsuranceLists {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(InsuranceLists.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        total: Int?? = nil,
        insurance: [Insurance]?? = nil
    ) -> InsuranceLists {
        return InsuranceLists(
            total: total ?? self.total,
            insurances: insurance ?? self.insurances
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
