struct FeatureFlag {
    
    // TODO fix this
    
    // Existing Flags
    static let oldSkillTreeImage = FeatureFlag(name: "oldskilltreeimage")
    static let campStatus = FeatureFlag(name: "campstatus")
    
    var name: String
    
    func isActive() -> Bool {
        return false
//        return OldDM.featureFlags.first(where: { ffm in
//            ffm.name.lowercased() == name.lowercased()
//        })?.isActiveIos ?? false
    }
    
    func isActiveAndroid() -> Bool {
        return false
//        return OldDM.featureFlags.first(where: { ffm in
//            ffm.name.lowercased() == name.lowercased()
//        })?.isActiveAndroid ?? false
    }
    
    func isActiveBoth() -> Bool {
        return false
//        let ff = OldDM.featureFlags.first(where: { ffm in
//            ffm.name.lowercased() == name.lowercased()
//        })
//        return ff?.isActiveIos ?? false && ff?.isActiveAndroid ?? false
    }
    
}
