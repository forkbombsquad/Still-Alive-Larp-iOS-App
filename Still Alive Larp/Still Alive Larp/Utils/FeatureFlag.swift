struct FeatureFlag {
    
    // Existing Flags
    static let oldSkillTreeImage = FeatureFlag(name: "oldskilltreeimage")
    static let campStatus = FeatureFlag(name: "campstatus")
    
    var name: String
    
    func isActive() -> Bool {
        return DataManager.shared.featureFlags?.first(where: { ffm in
            ffm.name.lowercased() == name.lowercased()
        })?.isActiveIos ?? false
    }
    
    func isActiveAndroid() -> Bool {
        return DataManager.shared.featureFlags?.first(where: { ffm in
            ffm.name.lowercased() == name.lowercased()
        })?.isActiveAndroid ?? false
    }
    
    func isActiveBoth() -> Bool {
        let ff = DataManager.shared.featureFlags?.first(where: { ffm in
            ffm.name.lowercased() == name.lowercased()
        })
        return ff?.isActiveIos ?? false && ff?.isActiveAndroid ?? false
    }
    
}
