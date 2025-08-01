//
//  LocalDataManager.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

import Foundation

class LocalDataManager {
    
    struct CollectionCompressorObject<C>: CustomCodeable, Identifiable where C: Collection & Codable, C.Element: Codable {
        var id = UUID()
        let collection: C
    }

    struct IntMapCompressorObject<Value: Codable>: CustomCodeable, Identifiable {
        var id = UUID()
        let collection: [Int: Value]
    }

    
    typealias DMT = DataManager.DataManagerType
    
    private class LDMKeys {
        static let ldmkeysPostfix = "_LDMKEYS_dm_ud_key"
        static let unpUserDefaultsKey = "StillAliveLarpUserDefaults"
        static let sharedPrefsBaseKey = "StillALiveLarpLocalDataPrefBaseKey"
        static let fullSkillsKey = "fullskills\(ldmkeysPostfix)"
        static let fullEventsKey = "fullevents\(ldmkeysPostfix)"
        static let fullCharactersKey = "fullcharacters\(ldmkeysPostfix)"
        static let fullPlayersKey = "fullplayers\(ldmkeysPostfix)"
        static let playerIdKey = "playerid\(ldmkeysPostfix)"
        
        static let allKeys = [fullSkillsKey, fullEventsKey, fullCharactersKey, fullPlayersKey, playerIdKey]
    }
    
    static let shared = LocalDataManager()
    
    // TODO ROUTINE - update this number if any of the models change between releases
    static let localDataVersion = "1.0.0.0"
    
    static func clearAllLocalData() {
        // TODO
        // UserAndPassManager.shared.clearAll()
        for key in LDMKeys.allKeys {
            shared.clear(key)
        }
        for type in DMT.allCases {
            shared.clear(type)
        }
    }
    
    private init() {}
    
    //
    // MARK: - Utils and Generics
    //
    
    private func getUnPUserDefaultsKey(_ key: String) -> String {
        return LDMKeys.unpUserDefaultsKey + "_\(key)"
    }
    
    func setUnPRelatedObject(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: getUnPUserDefaultsKey(key))
    }
    
    func getUnPRelatedObject(key: String) -> String? {
        return UserDefaults.standard.string(forKey: getUnPUserDefaultsKey(key))
    }
    
    private func getUserDefaultsKey(_ key: String) -> String {
        return LDMKeys.sharedPrefsBaseKey + LocalDataManager.localDataVersion + "_\(key)"
    }
    
    private func getUserDefaultsKey(_ key: DMT) -> String {
        return  getUserDefaultsKey(key.getLocalDataKey())
    }
    
    private func clear(_ key: String) {
        UserDefaults.standard.removeObject(forKey: getUserDefaultsKey(key))
    }
    
    private func clear(_ key: DMT) {
        clear(key.getLocalDataKey())
    }
    
    func clearUnPRelatedObject(key: String) {
        UserDefaults.standard.removeObject(forKey: getUnPUserDefaultsKey(key))
    }
    
    private func store(_ obj: CustomCodeable, key: String) {
        let json = obj.toJsonString() ?? ""
        let compressed = json.compress()
        UserDefaults.standard.set(compressed, forKey: getUserDefaultsKey(key))
    }
    
    private func store(_ obj: CustomCodeable, key: DMT) {
        store(obj, key: key.getLocalDataKey())
    }
    
    private func store<C>(_ obj: C, key: String) where C: Collection & Codable, C.Element: Codable {
        let collectionCompressor = CollectionCompressorObject(collection: obj)
        store(collectionCompressor, key: key)
    }
    
    private func store<C>(_ obj: C, key: DMT) where C: Collection & Codable, C.Element: Codable {
        store(obj, key: key.getLocalDataKey())
    }
    
    private func store<Value: Codable>(_ obj: [Int : Value], key: String) {
        let compressor = IntMapCompressorObject(collection: obj)
        store(compressor, key: key)
    }
    
    private func store<Value: Codable>(_ obj: [Int : Value], key: DMT) {
        store(obj, key: key.getLocalDataKey())
    }
    
    private func store(_ int: Int, key: String) {
        UserDefaults.standard.set(int, forKey: getUserDefaultsKey(key))
    }
    
    private func store(_ int: Int, key: DMT) {
        store(int, key: key.getLocalDataKey())
    }
    
    private func get<T: CustomCodeable>(_ key: String) -> T? {
        guard let compressed = UserDefaults.standard.data(forKey: getUserDefaultsKey(key)) else { return nil }
        guard let json = compressed.decompress() else { return nil }
        guard let obj: T = json.toJsonObject(as: T.self) else { return nil }
        return obj
    }
    
    private func get<T: CustomCodeable>(_ key: DMT) -> T? {
        return get(key.getLocalDataKey())
    }
    
    private func get<C>(_ key: String) -> C? where C: Collection & Codable, C.Element: CustomCodeable {
        guard let compressed = UserDefaults.standard.data(forKey: getUserDefaultsKey(key)) else { return nil }
        guard let json = compressed.decompress() else { return nil }
        guard let wrapper: CollectionCompressorObject<C> = json.toJsonObject() else { return nil }
        return wrapper.collection
    }
    
    private func get<C>(_ key: DMT) -> C? where C: Collection & Codable, C.Element: CustomCodeable {
        return get(key.getLocalDataKey())
    }
    
    private func get<Value: Codable>(_ key: String) -> [Int : Value]? {
        guard let compressed = UserDefaults.standard.data(forKey: getUserDefaultsKey(key)) else { return nil }
        guard let json = compressed.decompress() else { return nil }
        guard let wrapper: IntMapCompressorObject<Value> = json.toJsonObject() else { return nil }
        return wrapper.collection
    }
    
    private func get<Value: Codable>(_ key: DMT) -> [Int : Value]? {
        return get(key.getLocalDataKey())
    }
    
    private func get(_ key: String) -> Int? {
        return UserDefaults.standard.object(forKey: getUserDefaultsKey(key)) as? Int
    }
    
    //
    // MARK: - storing objects
    //
    
    func storeUpdateTracker(_ updateTracker: UpdateTrackerModel) {
        store(updateTracker, key: DMT.updateTracker)
    }
    
    func getUpdateTracker() -> UpdateTrackerModel? {
        return get(DMT.updateTracker)
    }
    
    func storeAnnouncements(_ announcements: [AnnouncementModel]) {
        store(announcements, key: DMT.announcements)
    }
    
    func getAnnouncements() -> [AnnouncementModel] {
        return get(DMT.announcements) ?? []
    }
    
    func storeAwards(awards: [AwardModel]) {
        var playerAwards: [Int : [AwardModel]] = [:]
        var charAwards: [Int : [AwardModel]] = [:]
        
        for award in awards {
            if let charId = award.characterId, charId != -1 {
                charAwards[charId, default: []].append(award)
            } else {
                playerAwards[award.playerId, default: []].append(award)
            }
        }
        let ams = LDAwardModels(playerAwards: playerAwards, characterAwards: charAwards)
        store(ams, key: DMT.awards)
    }
    
    func getAwards() -> LDAwardModels {
        return get(DMT.awards) ?? LDAwardModels(playerAwards: [:], characterAwards: [:])
    }
    
    func storeCharacters(_ characters: [CharacterModel]) {
        store(characters, key: DMT.characters)
    }
    
    func getCharacters() -> [CharacterModel] {
        return get(DMT.characters) ?? []
    }
    
    func storeGear(_ gear: [GearModel]) {
        var gearMap = [Int : GearModel]()
        for g in gear {
            gearMap[g.characterId] = g
        }
        store(gearMap, key: DMT.gear)
    }
    
    func getGear() -> [Int : GearModel] {
        return get(DMT.gear) ?? [:]
    }
    
    func storeCharacterSkills(_ skills: [CharacterSkillModel]) {
        var skillsMap: [Int : [CharacterSkillModel]] = [:]
        for s in skills {
            skillsMap[s.characterId, default: []].append(s)
        }
        store(skillsMap, key: DMT.characterSkills)
    }
    
    func getCharacterSkills() -> [Int : [CharacterSkillModel]] {
        return get(DMT.characterSkills) ?? [:]
    }
    
    func storeContactRequests(_ requests: [ContactRequestModel]) {
        store(requests, key: DMT.contactRequests)
    }
    
    func getContactRequests() -> [ContactRequestModel] {
        return get(DMT.contactRequests) ?? []
    }
    
    func storeEvents(_ events: [EventModel]) {
        store(events, key: DMT.events)
    }
    
    func getEvents() -> [EventModel] {
        return get(DMT.events) ?? []
    }
    
    func storeEventAttendees(_ attendees: [EventAttendeeModel]) {
        var eventMap: [Int : [EventAttendeeModel]] = [:]
        var playerMap: [Int : [EventAttendeeModel]] = [:]
        var charMap: [Int : [EventAttendeeModel]] = [:]
        
        for attendee in attendees {
            eventMap[attendee.eventId, default: []].append(attendee)
            playerMap[attendee.playerId, default: []].append(attendee)
            if let charId = attendee.characterId {
                charMap[charId, default: []].append(attendee)
            }
        }
        
        store(LDEventAttendeeModels(byEvent: eventMap, byPlayer: playerMap, byCharacter: charMap), key: DMT.eventAttendees)
    }
    
    func getEventAttendees() -> LDEventAttendeeModels {
        return get(DMT.eventAttendees) ?? LDEventAttendeeModels(byEvent: [:], byPlayer: [:], byCharacter: [:])
    }
    
    func storePreregs(_ preregs: [EventPreregModel]) {
        var eventMap: [Int : [EventPreregModel]] = [:]
        var playerMap: [Int : [EventPreregModel]] = [:]
        var charMap: [Int : [EventPreregModel]] = [:]
        var regTypeMap: [EventRegType : [EventPreregModel]] = [:]
        
        for prereg in preregs {
            eventMap[prereg.eventId, default: []].append(prereg)
            playerMap[prereg.playerId, default: []].append(prereg)
            if let charId = prereg.getCharId() {
                charMap[charId, default: []].append(prereg)
            }
            regTypeMap[prereg.eventRegType, default: []].append(prereg)
        }
        store(LDPreregModels(byEvent: eventMap, byPlayer: playerMap, byCharacter: charMap, byRegType: regTypeMap), key: DMT.preregs)
    }
    
    func getPreRegs() -> LDPreregModels {
        return get(DMT.preregs) ?? LDPreregModels(byEvent: [:], byPlayer: [:], byCharacter: [:], byRegType: [:])
    }
    
    func storeFeatureFlags(_ featureFlags: [FeatureFlagModel]) {
        store(featureFlags, key: DMT.featureFlags)
    }
    
    func getFeatureFlags() -> [FeatureFlagModel] {
        return get(DMT.featureFlags) ?? []
    }
    
    func storeIntrigues(_ intrigues: [IntrigueModel]) {
        var intrigueMap: [Int : IntrigueModel] = [:]
        for intrigue in intrigues {
            intrigueMap[intrigue.eventId] = intrigue
        }
        store(intrigueMap, key: DMT.intrigues)
    }
    
    func getIntrigues() -> [Int : IntrigueModel] {
        return get(DMT.intrigues) ?? [:]
    }
    
    func storePlayers(_ players: [PlayerModel]) {
        store(players, key: DMT.players)
    }
    
    func getPlayers() -> [PlayerModel] {
        return get(DMT.players) ?? []
    }
    
    func storeProfileImages(_ profileImages: [ProfileImageModel]) {
        var profileImageMap: [Int : ProfileImageModel] = [:]
        for profileImage in profileImages {
            profileImageMap[profileImage.playerId] = profileImage
        }
        store(profileImageMap, key: DMT.profileImages)
    }
    
    func getProfileImages() -> [Int : ProfileImageModel] {
        return get(DMT.profileImages) ?? [:]
    }
    
    func storeResearchProjects(_ researchProjects: [ResearchProjectModel]) {
        store(researchProjects, key: DMT.researchProjects)
    }
    
    func getResearchProjects() -> [ResearchProjectModel] {
        return get(DMT.researchProjects) ?? []
    }
    
    func storeSkills(_ skills: [SkillModel]) {
        store(skills, key: DMT.skills)
    }
    
    func getSkills() -> [SkillModel] {
        return get(DMT.skills) ?? []
    }
    
    func storeSkillCategories(_ skillCategories: [SkillCategoryModel]) {
        store(skillCategories, key: DMT.skillCategories)
    }
    
    func getSkillCategories() -> [SkillCategoryModel] {
        return get(DMT.skillCategories) ?? []
    }
    
    func storeSkillPrereqs(_ skillPrereqs: [SkillPrereqModel]) {
        var byBaseMap: [Int : [SkillPrereqModel]] = [:]
        var byPrereqMap: [Int : [SkillPrereqModel]] = [:]
        for prereq in skillPrereqs {
            byBaseMap[prereq.baseSkillId, default: []].append(prereq)
            byPrereqMap[prereq.prereqSkillId, default: []].append(prereq)
        }
        store(LDSkillPrereqModels(all: skillPrereqs, byBaseSkill: byBaseMap, byPrereqSkill: byPrereqMap), key: DMT.skillPrereqs)
    }
    
    func getSkillPrereqs() -> LDSkillPrereqModels {
        return get(DMT.skillPrereqs) ?? LDSkillPrereqModels(all: [], byBaseSkill: [:], byPrereqSkill: [:])
    }
    
    func storeXpReductions(_ xpReductions: [SpecialClassXpReductionModel]) {
        var xpReductionMap: [Int : [SpecialClassXpReductionModel]] = [:]
        for xpReduction in xpReductions {
            xpReductionMap[xpReduction.characterId, default: []].append(xpReduction)
        }
        store(xpReductionMap, key: DMT.xpReductions)
    }
    
    func getXpReductions() -> [Int : [SpecialClassXpReductionModel]] {
        return get(DMT.xpReductions) ?? [:]
    }
    
    func storeRulebook(_ rulebook: Rulebook) {
        store(rulebook, key: DMT.rulebook)
    }
    
    func getRulebook() -> Rulebook? {
        return get(DMT.rulebook)
    }
    
    // TODO
//    func storeCampStatus(_ campStatus: CampStatusModel) {
//        store(campStatus, DMT.campStatus)
//    }
//    
//    func getCampStatus() -> CampStatusModel? {
//        return get(DMT.campStatus)
//    }
    
    func storeTreatingWounds(_ treatingWounds: Data) {
        store(LDImageDataModel(imageData: treatingWounds), key: DMT.treatingWounds)
    }
    
    func getTreatingWounds() -> Data? {
        let dm: LDImageDataModel? = get(DMT.treatingWounds)
        return dm?.imageData
    }
    
    func storePlayerId(_ playerId: Int) {
        store(playerId, key: LDMKeys.playerIdKey)
    }
    
    func getPlayerId() -> Int {
        return get(LDMKeys.playerIdKey) ?? -1
    }
    
    //
    // MARK - Functionality and Updates
    //
    
    func determineWhichTypesNeedUpdates(_ newUpdateTracker: UpdateTrackerModel) -> [DMT] {
        return getUpdateTracker()?.getDifferences(newUpdateTracker) ?? DMT.allCases.filter({ $0 != .updateTracker })
    }
    
    func updatesSucceeded(_ newUpdateTracker: UpdateTrackerModel, successfulUpdates: [DMT]) {
        if var oldTracker = getUpdateTracker() {
            oldTracker.updateInPlace(newUpdateTracker, successfulUpdates: successfulUpdates)
            storeUpdateTracker(oldTracker)
        } else {
            storeUpdateTracker(newUpdateTracker.updateToNew(successfulUpdates))
        }
        recalculateFullModels(newUpdateTracker)
    }
    
    private func recalculateFullModels(_ newUpdateTracker: UpdateTrackerModel) {
        let neededUpdates = determineWhichTypesNeedUpdates(newUpdateTracker)
        var builtFullSkills = true
        var builtFullEvents = true
        var builtFullCharacters = true
        
        let attendees = getEventAttendees()
        let preregs = getPreRegs()
        let awards = getAwards()
        
        // Full Skills
        if neededUpdates.doesNotContainAnyOf([.skills, .skillCategories, .skillPrereqs]) {
            buildAndStoreFullSkills(getSkills(), getSkillCategories(), getSkillPrereqs())
            builtFullSkills = true
        } else if getFullSkills().isEmpty {
            builtFullSkills = false
        }
        
        // Full Events
        if neededUpdates.doesNotContainAnyOf([.events, .eventAttendees, .preregs, .intrigues]) {
            buildAndStoreFullEvents(getEvents(), attendees, preregs, getIntrigues())
            builtFullEvents = true
        } else if getFullEvents().isEmpty {
            builtFullEvents = false
        }
        
        // Full Characters
        if (builtFullSkills && builtFullEvents && neededUpdates.doesNotContainAnyOf([.characters, .characterSkills, .gear])) {
            buildAndStoreFullCharacters(
                characters: getCharacters(),
                fullSkills: getFullSkills(),
                characterSkills: getCharacterSkills(),
                gear: getGear(),
                awards: awards,
                attendees: attendees,
                preregs: preregs,
                xpReductions: getXpReductions()
            )
        } else if getFullCharacters().isEmpty {
            builtFullCharacters = false
        }
        
        // Full Players
        if (builtFullCharacters && builtFullEvents && neededUpdates.doesNotContainAnyOf([.players, .profileImages])) {
            buildAndStoreFullPlayers(
                players: getPlayers(),
                characters: getFullCharacters(),
                awards: awards,
                attendees: attendees,
                preregs: preregs,
                profileImages: getProfileImages()
            )
        }
    }
    
    private func buildAndStoreFullSkills(_ skills: [SkillModel], _ skillCategories: [SkillCategoryModel], _ skillPrereqs: LDSkillPrereqModels) {
        // TODO
    }
    
    private func getFullSkills() -> [FullSkillModel] {
        // TODO
        return []
    }
    
    private func buildAndStoreFullEvents(_ events: [EventModel], _ attendees: LDEventAttendeeModels, _ prereqs: LDPreregModels, _ intrigues: [Int : IntrigueModel]) {
        // TODO
    }
    
    private func getFullEvents() -> [FullEventModel] {
        // TODO
        return []
    }
    
    private func buildAndStoreFullCharacters(characters: [CharacterModel], fullSkills: [FullSkillModel], characterSkills: [Int : [CharacterSkillModel]], gear: [Int : GearModel], awards: LDAwardModels, attendees: LDEventAttendeeModels, preregs: LDPreregModels, xpReductions: [Int : [SpecialClassXpReductionModel]]) {
        // TODO
    }
    
    private func getFullCharacters() -> [OldFullCharacterModel] {
        // TODO
        return []
    }
    
    private func buildAndStoreFullPlayers(players: [PlayerModel], characters: [OldFullCharacterModel], awards: LDAwardModels, attendees: LDEventAttendeeModels, preregs: LDPreregModels, profileImages: [Int : ProfileImageModel]) {
        // TODO
    }
    
    private func getFullPlayers() -> [FullPlayerModel] {
        // TODO
        return []
    }
    
}
