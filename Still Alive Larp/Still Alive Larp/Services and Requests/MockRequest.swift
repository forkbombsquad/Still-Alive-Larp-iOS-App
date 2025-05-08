//
//  MockRequest.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import Foundation

struct MockRequest {

    let url: URL
    let urlString: String
    let requestType: ServiceController.RequestType
    let endpoint: ServiceEndpoints.Endpoint

    let headers: [String : String]
    let body: Data?
    private(set) var params: [String : String]

    init(url: URL, requestType: ServiceController.RequestType, endpoint: ServiceEndpoints.Endpoint, headers: [String : String], body: Data?) {
        self.url = url
        self.requestType = requestType
        self.headers = headers
        self.body = body
        self.endpoint = endpoint

        urlString = url.absoluteString
        if urlString.contains("?") {
            let splitArray = urlString.splitToStringArray("?")
            var splitString = ""
            var counter = -1
            for part in splitArray {
                counter += 1
                guard counter > 0 else { continue }
                splitString.append(counter == 1 ? part : "?\(part)")
            }
            let paramArray = splitString.splitToStringArray("&")
            params = [:]
            for param in paramArray {
                let keyVal = param.splitToStringArray("=")
                params[keyVal[0]] = keyVal[1]
            }
        } else {
            params = [:]
        }
    }

    func getResponse<T>() -> T? {
        return getMockData().getResponse(self) as? T
    }

}
