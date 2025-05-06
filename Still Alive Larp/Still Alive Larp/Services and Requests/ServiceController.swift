//
//  ServiceController.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/4/22.
//

import Foundation
import SwiftUI

// Global Typealias
typealias FailureCase = (_ error: Error) -> Void

enum ServiceErrors: Error {
    case invalidUrl
    case malformedJsonBody
    case failedToParseResponse
    case failedToMapToObject
    case failedToCompressObject
    case serverError(String)
}

extension ServiceErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidUrl:
                return NSLocalizedString("Invalid Url", comment: "")
            case .malformedJsonBody:
                return NSLocalizedString("Malformed Json", comment: "")
            case .failedToParseResponse:
                return NSLocalizedString("Failed to parse response", comment: "")
            case .failedToMapToObject:
                return NSLocalizedString("Failed to map response", comment: "")
            case .failedToCompressObject:
                return NSLocalizedString("Failed to compress object", comment: "")
            case .serverError(let detail):
                return NSLocalizedString(detail, comment: "")
        }
    }
}

struct ServiceController {

    struct ServiceSuccess<T: Decodable> {
        let data: Data
        let response: HTTPURLResponse
        var jsonObject: T
    }

    enum ContentType: String {
        case json = "application/json"
        case urlEncoded = "application/x-www-form-urlencoded"
    }

    enum RequestType: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }

    static func makeRequest<T>(_ endpoint: ServiceEndpoints.Endpoint, addToEndOfUrl: String? = nil, contentType: ContentType = .json, headers: [String: String]? = nil, params: [String: Any]? = nil, bodyParams: [String: Any]? = nil, bodyJson: Encodable? = nil, responseObject: T.Type, sendToken: Bool = true, sendUserAndPass: Bool = true, overrideDefaultErrorBehavior: Bool = false, success: @escaping (_ success: ServiceSuccess<T>) -> Void, failureCase: @escaping FailureCase) {
        if sendToken {
            AuthManager.shared.getAuthToken { token in
                var newHeaders = headers ?? [:]
                newHeaders["Authorization"] = "Bearer \(token ?? "")"
                ServiceController.makeRequest(endpoint, addToEndOfUrl: addToEndOfUrl, contentType: contentType, headers: newHeaders, params: params, bodyParams: bodyParams, bodyJson: bodyJson, responseObject: responseObject, sendToken: false, sendUserAndPass: sendUserAndPass, overrideDefaultErrorBehavior: overrideDefaultErrorBehavior, success: success, failureCase: failureCase)
            }
        } else {
            var failure: FailureCase = failureCase
            if !overrideDefaultErrorBehavior {
                // Default failure behavior does some basic stuff before loading. Only override if necessary
                failure = { error in
                    AlertManager.shared.showOkAlert("Server Error", message: error.localizedDescription, onOkAction: {})
                    globalPrintServiceLogs("SERVICE ERROR: \(error)")
                    failureCase(error)
                }
            }

            var urlString = ServiceEndpoints.getUrl(endpoint)
            if let aeu = addToEndOfUrl {
                urlString = "\(urlString)\(aeu)"
            }
            let requestType = endpoint.requestType
            var fullUrlString = urlString

            if let params = params {
                var paramData = [String]()
                for param in params {
                    paramData.append("\(param.key)=\(param.value)")
                }
                let map = paramData.map { String($0) }.joined(separator: "&")
                fullUrlString += "?\(map)"
            }

            guard let url = URL(string: fullUrlString) else {
                failure(ServiceErrors.invalidUrl)
                return
            }

            let requestBuilder = RequestBuilder(url, endpoint: endpoint, requestType: requestType, contentType: contentType)

            var newHeaders = headers ?? [:]
            if sendUserAndPass, let u = UserAndPassManager.shared.getU(), let p = UserAndPassManager.shared.getP() {
                newHeaders["em"] = u
                newHeaders["pp"] = p
            }
            newHeaders["Accept-Encoding"] = "gzip"

            requestBuilder.addHeaders(newHeaders)

            if let bodyParams = bodyParams {
                requestBuilder.setBodyParams(bodyParams)
            } else if let bodyJson = bodyJson {
                requestBuilder.setJsonBody(bodyJson, failure: failure)
            }

            switch Constants.ServiceOperationMode.serviceMode {
            case .prod:
                let request = requestBuilder.getUrlRequest()
                
                globalPrintServiceLogs("SERVICE CONTROLLER: Request:\n\(request)")
                globalPrintServiceLogs("SERVICE CONTROLLER: Headers")
                for (key, value) in request.allHTTPHeaderFields ?? [:] {
                    globalPrintServiceLogs("SERVICE CONTROLLER: Header - \(key): \(value)")
                }
                if var body = request.httpBody {
                    globalPrintServiceLogs("SERVICE CONTROLLER: Request Body:\n\(String(data: body, encoding: .utf8) ?? "Unknown")")
                }

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        failure(error)
                    } else if let rsp = response as? HTTPURLResponse {
                        let d = data ?? Data()
                        
                        globalPrintServiceLogs("SERVICE CONTROLLER: Response\n\(String(data: d, encoding: .utf8) ?? "")")

                        if let jsonObject: T = d.toJsonObject() {
                            success(ServiceSuccess(data: d, response: rsp, jsonObject: jsonObject))
                        } else if let errorObject: ErrorModel = d.toJsonObject() {
                            failure(ServiceErrors.serverError(errorObject.detail))
                        } else {
                            failure(ServiceErrors.failedToMapToObject)
                        }

                    } else {
                        failure(ServiceErrors.failedToParseResponse)
                    }
                }
                task.resume()
            case .test:
                let mockRequest = requestBuilder.getMockRequest()
                globalPrintServiceLogs("SERVICE CONTROLLER: Mock Request:\n\(mockRequest)")

                if let responseObject: T = mockRequest.getResponse() {
                    success(ServiceSuccess(data: Data(), response: HTTPURLResponse(), jsonObject: responseObject))
                } else {
                    failure(ServiceErrors.failedToMapToObject)
                }

            }

        }

    }

}
