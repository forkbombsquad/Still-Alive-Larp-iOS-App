//
//  FileStorageManager.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/8/25.
//

import Foundation

class FileStorageManager {
    static let shared = FileStorageManager()
    
    private init() {}
    
    private func fileURL(for key: String) -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("\(key).data")
    }
    
    func write(_ data: Data?, forKey key: String) {
        guard let data = data else {
            globalTestPrint("❌ Data for key \(key) was null")
            return
        }
        let url = fileURL(for: key)
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            globalTestPrint("❌ FileStorageManager: Failed to write \(key): \(error)")
        }
    }
    
    func read(forKey key: String) -> Data? {
        let url = fileURL(for: key)
        return try? Data(contentsOf: url)
    }
    
    func remove(forKey key: String) {
        let url = fileURL(for: key)
        try? FileManager.default.removeItem(at: url)
    }
    
    func clearAll() {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }
        for file in files where file.pathExtension == "data" {
            try? FileManager.default.removeItem(at: file)
        }
    }
}
