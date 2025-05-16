//
//  GlobalFunctions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/27/23.
//

import Foundation
import SwiftUI

func runOnMainThread(_ code: @escaping () -> Void) {
    DispatchQueue.main.async {
        code()
    }
}

func getBuildNumber() -> Int {
    return (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0").intValueDefaultZero
}

func forceResetAllPlayerData() {
    runOnMainThread {
        DataManager.forceReset()
        LocalDataHandler.forceReset()
        UserAndPassManager.forceReset()
        PlayerManager.forceReset()
        CharacterManager.forceReset()
    }
}

func globalPrintServiceLogs(_ message: String) {
    if Constants.Logging.showServiceLogging {
        print(message)
    }
}

func globalTestPrint(_ message: String) {
    if Constants.Logging.showTestLogging {
        print(message)
    }
}

func getMockData(_ index: Int = 0) -> MockData {
    return MockDataManagement.allMockData[index]
}

func globalState<T>(_ variable: T) -> State<T> {
    return State(initialValue: variable)
}

func max(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
    return CGFloat.maximum(x, y)
}
