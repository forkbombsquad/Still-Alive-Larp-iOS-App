//
//  ImageDownloader.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/6/24.
//

import Foundation
import SwiftSoup
import UIKit

class ImageDownloader {

    enum ImageKey: String {
        case skillTree = "skillTree"
        case skillTreeDark = "skillTreeDark"
        case treatingWounds = "treatingWounds"

        var baseUrl: String {
            switch self {
                case .skillTree:
                    "https://stillalivelarp.com/skilltree"
                case .skillTreeDark:
                    "https://stillalivelarp.com/skilltree/dark"
                case .treatingWounds:
                    "https://stillalivelarp.com/healing"
            }
        }
    }
    
    func downloadReturningImage(key: ImageKey, onCompletion: @escaping (_ imageData: Data?) -> Void) {
        downloadPage(urlString: key.baseUrl) { imagePath in
            guard let imagePath = imagePath else {
                onCompletion(nil)
                return
            }
            self.downloadFromUrlForImage(path: imagePath, key: key) { img in
                onCompletion(img)
            }
        }
    }
    
    private func downloadFromUrlForImage(path: String, key: ImageKey, onCompletion: @escaping (_ imageData: Data?) -> Void) {
        guard let url = URL(string: path) else {
            onCompletion(nil)
            return
        }
        downloadImage(from: url) { data in
            guard let data = data else {
                onCompletion(nil)
                return
            }
            onCompletion(data)
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func downloadImage(from url: URL, onCompletion: @escaping (_ data: Data?) -> Void) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                onCompletion(nil)
                return
            }
            onCompletion(data)
        }
    }

    private func downloadPage(urlString: String, onCompletion: @escaping (_ imagePath: String?) -> Void) {
        guard let url = URL(string: urlString) else {
            onCompletion(nil)
            return
        }
        guard let html = try? String(contentsOf: url) else {
            onCompletion(nil)
            return
        }
        guard let document = try? SwiftSoup.parse(html) else {
            onCompletion(nil)
            return
        }
        onCompletion(getImagePath(document))
    }

    private func getImagePath(_ document: Document) -> String? {
        let imageElement = try? document.getElementById("image")
        return try? imageElement?.attr("src")
    }

}
