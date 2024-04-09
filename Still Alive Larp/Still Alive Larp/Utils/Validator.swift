//
//  Validator.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/18/22.
//

import Foundation

class ValidationResult {

    private(set) var hasError = false
    private var errorMessages: String? = nil

    init(hasError: Bool = false, errorMessages: String? = nil) {
        self.hasError = hasError
        self.errorMessages = errorMessages
    }

    func addErrorMessage(_ errorMessage: String) {
        if errorMessages == nil {
            errorMessages = ""
            hasError = true
        } else {
            errorMessages = "\(errorMessages!)\n"
        }
        errorMessages = "\(errorMessages!) \(errorMessage)"
    }

    func getErrorMessages() -> String {
        return errorMessages ?? ""
    }

}

struct ValidationGroup {
    let text: String
    let validationType: ValidationType
}



enum ValidationType: String {
    case fullName = "Full Name"
    case email = "Email"
    case password = "Password"
    case securityCode = "Security Code"
    case announcementTitle = "Announcement Title"
    case announcementMessage = "Announcement Message"
    case date = "Date"
    case title = "Title"
    case description = "Description"
    case startTime = "Start Time"
    case endTime = "End Time"
    case postalCode = "Postal Code"
    case message = "Message"
    case intrigue = "Intrigue Message"
    case infection = "Infection"
    case bullets = "Bullets"
    case megas = "Megas"
    case rivals = "Rivals"
    case rockets = "Rockets"
    case bulletCasings = "Bullet Casings"
    case clothSupplies = "Cloth Supplies"
    case woodSupplies = "Wood Supplies"
    case metalSupplies = "Metal Supplies"
    case techSupplies = "Tech Supplies"
    case medicalSupplies = "Medical Supplies"
    case primaryWeaponName = "Primary Weapon Name"
    case primaryWeaponAmmo = "Primary Weapon Ammo"
    case gearType = "Gear Type"
    case gearName = "Gear Name"
    case gearDesc = "Gear Description"

    var subtypes: [ValidationSubtype] {
        switch self {
            case .fullName:
                return [.notEmpty, .atLeastFiveCharactersLong, .needsSpace]
            case .email:
                return [.notEmpty, .emailStyle, .atLeastEightCharactersLong]
            case .password:
                return [.notEmpty, .atLeastEightCharactersLong]
            case .securityCode, .description, .startTime, .endTime:
                return [.notEmpty]
            case .announcementTitle, .announcementMessage, .title:
                return [.notEmpty, .atLeastFiveCharactersLong]
            case .date:
                return [.notEmpty, .exactlyTenCharactersLong, .dateFormatted]
            case .postalCode:
                return [.notEmpty, .between5and7CharactersLong]
            case .message, .intrigue:
                return [.notEmpty]
            case .infection:
                return [.allNumbers, .between0and100]
            case .bullets:
                return [.allNumbers]
            case .megas:
                return [.allNumbers]
            case .rivals:
                return [.allNumbers]
            case .rockets:
                return [.allNumbers]
            case .bulletCasings:
                return [.allNumbers]
            case .clothSupplies:
                return [.allNumbers]
            case .woodSupplies:
                return [.allNumbers]
            case .metalSupplies:
                return [.allNumbers]
            case .techSupplies:
                return [.allNumbers]
            case .medicalSupplies:
                return [.allNumbers]
            case .primaryWeaponAmmo, .primaryWeaponName, .gearType, .gearName, .gearDesc:
                return [.notEmpty, .atLeastTwoCharactersLong]
        }
    }

}

enum ValidationSubtype {
    case notEmpty, needsSpace, atLeastFiveCharactersLong, emailStyle, atLeastEightCharactersLong, exactlyTenCharactersLong, dateFormatted, between5and7CharactersLong, allNumbers, between0and100, atLeastTwoCharactersLong
}

class Validator {

    static func validateMultiple(_ validationGroups: [ValidationGroup]) -> ValidationResult {
        let validationResult = ValidationResult()
        for validationGroup in validationGroups {
            let vr = validate(validationGroup)
            if vr.hasError {
                validationResult.addErrorMessage(vr.getErrorMessages())
            }
        }
        return validationResult
    }

    static func validate(_ validationGroup: ValidationGroup) -> ValidationResult {
        return validate(validationGroup.text, validationType: validationGroup.validationType)
    }

    static func validate(_ text: String, validationType: ValidationType) -> ValidationResult {
        let validationResult = ValidationResult()
        if let error = doValidation(text, validationType: validationType) {
            validationResult.addErrorMessage(error)
        }
        return validationResult
    }

    private static func doValidation(_ text: String, validationType: ValidationType) -> String? {
        var error = ""
        let name = validationType.rawValue
        for subtype in validationType.subtypes {
            switch subtype {

            case .notEmpty:
                if text == "" {
                    error = addToError(error, text: "\(name) must not be empty")
                }
            case .needsSpace:
                if !text.contains(" ") {
                    error = addToError(error, text: "\(name) must contain a space")
                }
            case .atLeastFiveCharactersLong:
                if text.count < 5 {
                    error = addToError(error, text: "\(name) must be at least 5 characters long")
                }
            case .emailStyle:
                if !text.contains("@") {
                    error = addToError(error, text: "\(name) must contain @")
                }
                if !text.contains(".") {
                    error = addToError(error, text: "\(name) must contain .")
                }
            case .atLeastEightCharactersLong:
                if text.count < 8 {
                    error = addToError(error, text: "\(name) must be at least 8 characters long")
                }
            case .exactlyTenCharactersLong:
                if text.count != 10 {
                    error = addToError(error, text: "\(name) must be exactly 10 characters long")
                }
            case .dateFormatted:
                let spl = text.splitToStringArray("/")
                if spl.count != 3 {
                    error = addToError(error, text: "\(name) must formatted exactly as yyyy/MM/dd, ie. 2023/23/01")
                } else {
                    if spl[0].count != 4 || spl[1].count != 2 || spl[2].count != 2 {
                        error = addToError(error, text: "\(name) must formatted exactly as yyyy/MM/dd, ie. 2023/23/01")
                    } else {
                        if spl[0].intValueDefaultZero == 0 || spl[1].intValueDefaultZero == 0 || spl[2].intValueDefaultZero == 0 {
                            error = addToError(error, text: "\(name) must formatted exactly as yyyy/MM/dd, ie. 2023/23/01")
                        }
                    }
                }
            case .between5and7CharactersLong:
                if text.count < 5 || text.count > 7 {
                    error = addToError(error, text: "\(name) must be between 5 and 7 characters long")
                }
            case .allNumbers:
                if text.intValue == nil {
                    error = addToError(error, text: "\(name) must consist of only numbers!")
                }
            case .between0and100:
                if text.intValueDefaultZero < 0 || text.intValueDefaultZero > 100 {
                    error = addToError(error, text: "\(name) must be between 0 and 100!")
                }
            case .atLeastTwoCharactersLong:
                if text.count < 2 {
                    error = addToError(error, text: "\(name) must be at least 2 characters long")
                }
            }
        }
        return error == "" ? nil : error
    }

    private static func addToError(_ error: String, text: String) -> String {
        return "\(error)\(error == "" ? "" : "\n")\(text)"
    }

}
