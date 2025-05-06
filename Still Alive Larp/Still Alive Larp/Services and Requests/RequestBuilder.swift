//
//  RequestBuilder.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import Foundation
import Gzip

class RequestBuilder {

    private(set) var url: URL
    private(set) var requestType: ServiceController.RequestType
    private(set) var endpoint: ServiceEndpoints.Endpoint

    private(set) var headers = [String : String]()
    private(set) var body: Data?

    init(_ url: URL, endpoint: ServiceEndpoints.Endpoint, requestType: ServiceController.RequestType, contentType: ServiceController.ContentType) {
        self.url = url
        self.requestType = requestType
        self.endpoint = endpoint

        setContentType(contentType)
    }

    func setContentType(_ contentType: ServiceController.ContentType) {
        headers["Content-Type"] = contentType.rawValue
    }

    func addHeaders(_ newHeaders: [String : String]) {
        headers.addInPlace(newHeaders)
    }

    func setBodyParams(_ bodyParams: [String : Any]) {
        var paramData = [String]()
        for param in bodyParams {
            paramData.append("\(param.key)=\(param.value)")
        }
        let map = paramData.map { String($0) }.joined(separator: "&")
        body = map.data(using: .utf8)
    }

    func setJsonBody(_ jsonBody: Encodable, failure: @escaping (_ error: Error) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(jsonBody) else {
            failure(ServiceErrors.malformedJsonBody)
            return
        }
        
        body = jsonData
    }

    func getUrlRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpBody = body
        return request
    }

    func getMockRequest() -> MockRequest {
        MockRequest(url: url, requestType: requestType, endpoint: endpoint, headers: headers, body: body)
    }

}
