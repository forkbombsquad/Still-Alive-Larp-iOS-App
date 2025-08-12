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
    // TODO
//    runOnMainThread {
//        OldDataManager.forceReset()
//        OldLocalDataHandler.forceReset()
//        UserAndPassManager.forceReset()
//        PlayerManager.forceReset()
//        CharacterManager.forceReset()
//    }
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

func globalStateObject<T>(_ variable: T) -> StateObject<T> {
    return StateObject(wrappedValue: variable)
}

func max(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
    return CGFloat.maximum(x, y)
}

func getViewName<T: View>(_ view: T.Type) -> String {
    return String(describing: view)
}

func getViewName<T: View>(_ view: T) -> String {
    return String(describing: type(of: view))
}

func globalStyleHtmlForRulebook(_ html: String) -> String {
    html
        .replacingHtmlTagWithTag("skill", with: "b")
        .replacingHtmlTagWithTagAndInnerValue("combat", with: "font", innerValue: "color='#910016'")
        .replacingHtmlTagWithTagAndInnerValue("profession", with: "font", innerValue: "color='#0D8017'")
        .replacingHtmlTagWithTagAndInnerValue("talent", with: "font", innerValue: "color='#007AFF'")
        .replacingHtmlTagWithTag("item", with: "i")
        .replacingHtmlTagWithTag("condition", with: "u")
}

