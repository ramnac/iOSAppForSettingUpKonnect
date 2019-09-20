//
//  CustomError.swift
//  konnect
//
//  Created by Ram on 21/09/19.
//  Copyright © 2019 andersenev. All rights reserved.
//

import Foundation

enum CustomError: Error {
    case discoverServicesError
    case discoverCharacteristicsForServiceError
    case updateValueForCharacteristicError
}

extension CustomError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .discoverServicesError:
            return Constants.Bluetooth.Error.discoverServicesError.rawValue
        case .discoverCharacteristicsForServiceError:
            return Constants.Bluetooth.Error.discoverCharacteristicsForServiceError.rawValue
        case .updateValueForCharacteristicError:
            return Constants.Bluetooth.Error.updateValueForCharacteristicError.rawValue
        }
    }
}
