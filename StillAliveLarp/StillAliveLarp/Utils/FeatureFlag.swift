struct FeatureFlag {
    
    // Existing Flags
    static let oldSkillTreeImage = FeatureFlag(name: "oldskilltreeimage")
    static let campStatus = FeatureFlag(name: "campstatus")
    
    var name: String
    
    func isActive(DM: DataManager) -> Bool {
        return DM.featureFlags.first(where: { ffm in
            ffm.name.lowercased() == name.lowercased()
        })?.isActiveIos ?? false
    }
    
    func isActiveAndroid(DM: DataManager) -> Bool {
        return DM.featureFlags.first(where: { ffm in
            ffm.name.lowercased() == name.lowercased()
        })?.isActiveAndroid ?? false
    }
    
    func isActiveBoth(DM: DataManager) -> Bool {
        return isActive(DM: DM) && isActiveAndroid(DM: DM)
    }
    
}
