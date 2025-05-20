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
                    AlertManager.shared.showOkAlert("Server Error", message: error.localizedDescription + "\n\nIf you are seeing this error, please take a screenshot of it and post it in the bug-reports channel of the Still Alive Discord Server along with some details about what you did before getting this message!", onOkAction: {})
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
                
                self.logRequest(request)

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        failure(error)
                    } else if let rsp = response as? HTTPURLResponse {
                        let d = data ?? Data()
                        
                        logResponse(rsp, d)

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
                self.logRequest(mockRequest)
                globalPrintServiceLogs("SERVICE CONTROLLER: Mock Request:\n\(mockRequest)")

                if let responseObject: T = mockRequest.getResponse() {
                    success(ServiceSuccess(data: Data(), response: HTTPURLResponse(), jsonObject: responseObject))
                } else {
                    failure(ServiceErrors.failedToMapToObject)
                }

            }

        }

    }
    
    private static func logRequest(_ request: URLRequest) {
        var requestLog = ""
        requestLog.buildJsonLine(key: "SERVICE CONTROLLER REQUEST", value: "{", indentValue: 0, addNewline: false, addComma: false)
        requestLog.buildJsonLine(key: "Endpoint", value: "\(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")", indentValue: 1)
        requestLog.buildJsonLine(key: "Headers", value: request.allHTTPHeaderFields ?? [:], indentValue: 1)
        if let body = request.httpBody {
            requestLog.buildJsonLine(key: "Body", value: "\(String(data: body, encoding: .utf8) ?? "Unknown")", indentValue: 1)
        }
        requestLog += "\n}"
        
        globalPrintServiceLogs(requestLog)
    }
    
    private static func logRequest(_ request: MockRequest) {
        var requestLog = ""
        requestLog.buildJsonLine(key: "SERVICE CONTROLLER REQUEST", value: "{", indentValue: 0, addNewline: false, addComma: false)
        requestLog.buildJsonLine(key: "Endpoint", value: "\(request.requestType.rawValue) \(request.urlString)", indentValue: 1)
        requestLog.buildJsonLine(key: "Headers", value: request.headers, indentValue: 1)
        if let body = request.body {
            requestLog.buildJsonLine(key: "Body", value: "\(String(data: body, encoding: .utf8) ?? "Unknown")", indentValue: 1)
        }
        requestLog += "\n}"
        
        globalPrintServiceLogs(requestLog)
    }
    
    private static func logResponse(_ response: HTTPURLResponse, _ data: Data) {
        var responseLog = ""
        responseLog.buildJsonLine(key: "SERVICE CONTROLLER RESPONSE", value: "{", indentValue: 0, addNewline: false, addComma: false)
        responseLog.buildJsonLine(key: "Endpoint", value: "\(response.statusCode.stringValue) \(response.url?.absoluteString ?? "")", indentValue: 1)
        responseLog.buildJsonLine(key: "Headers", value: response.allHeaderFields, indentValue: 1)
        responseLog.buildJsonLine(key: "Body", value: String(data: data, encoding: .utf8) ?? "", indentValue: 1)
        responseLog += "\n}"
        
        globalPrintServiceLogs(responseLog)
    }

}
