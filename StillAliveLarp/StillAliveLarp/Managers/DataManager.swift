//
//  DataManager.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

import SwiftUI
import SwiftSoup

class DataManager: ObservableObject {
    
    private init() { }
    
    enum DataManagerPassedDataKey {
        case barcode,
             selectedEvent,
             selectedPlayer,
             selectedCharacter,
             awardsList,
             characterList,
             destinationView,
             viewTitle,
             playerList,
             eventList,
             additionalDestinationView,
             contactRequestList,
             selectedContactRequest,
             featureFlagList,
             selectedFeatureFlag,
             researchProjectList,
             skillList,
             action,
             rulebook,
             image,
             campStatus
    }
    
    enum DataManagerType: String, CaseIterable {
        case updateTracker = "updateTracker_dm_ud_key"
        case announcements = "announcements_dm_ud_key"
        case awards = "awards_dm_ud_key"
        case characters = "characters_dm_ud_key"
        case gear = "gear_dm_ud_key"
        case characterSkills = "characterSkills_dm_ud_key"
        case contactRequests = "contactRequests_dm_ud_key"
        case events = "events_dm_ud_key"
        case eventAttendees = "eventAttendees_dm_ud_key"
        case preregs = "preregs_dm_ud_key"
        case featureFlags = "featureFlags_dm_ud_key"
        case intrigues = "intrigues_dm_ud_key"
        case players = "players_dm_ud_key"
        case profileImages = "profileImages_dm_ud_key"
        case researchProjects = "researchProjects_dm_ud_key"
        case skills = "skills_dm_ud_key"
        case skillCategories = "skillCategories_dm_ud_key"
        case skillPrereqs = "skillPrereqs_dm_ud_key"
        case xpReductions = "xpReductions_dm_ud_key"
        case rulebook = "rulebook_dm_ud_key"
        case treatingWounds = "treatingWounds_dm_ud_key"
        case campStatus = "campStatus_dm_ud_key"
        
        func getLocalDataKey() -> String {
            return rawValue
        }
    }
    
    enum DataManagerLoadType {
        case offline, downloadIfNecessary, forceDownload
    }
    
    @ObservedObject static private(set) var shared = DataManager()
    
    //
    // MARK: - Settings
    //
    
    @Published var actionState: Int? = 0
    @Published private(set) var debugMode: Bool = false
    @Published private(set) var offlineMode: Bool = false
    @Published private(set) var currentPlayerId: Int = -1
    // TODO remove if not needed
//    @Published private var updateCallbacks: [String: () -> Void] = [:]
//    @Published private var passedData: [String: Any] = [:]
    
    @Published var loadingText: String = ""
    let loadingActor = LoadingActor()
    let finishedCountActor = FinishedCountActor()
    
    @Published var isLoadingMirror: Bool = false
    
    actor LoadingActor {
        private var firstLoad: Bool = true
        private var loading: Bool = false
        private var stepCallbacks: [() -> Void] = []
        private var callbacks: [() -> Void] = []
        
        // Returns previous loading state
        func add(step: @escaping () -> Void, finished: @escaping () -> Void) -> Bool {
            let prevLoading = loading
            stepCallbacks.append(step)
            callbacks.append(finished)
            return prevLoading
        }
        
        func setLoading(_ value: Bool) {
            loading = value
        }
        
        func getLoading() -> Bool {
            return loading
        }
        
        func setFirstLoad(_ value: Bool) {
            firstLoad = value
        }
        
        func getFirstLoad() -> Bool {
            return firstLoad
        }
        
        func callStepCallbacks() {
            stepCallbacks.forEach { $0() }
        }
        
        func callCallbacks() {
            callbacks.forEach { $0() }
        }
        
        func clearStepCallbacks() {
            stepCallbacks.removeAll()
        }
        
        func clearCallbacks() {
            callbacks.removeAll()
        }
        
    }
    
    actor FinishedCountActor {
        private var currentUpdateTracker: UpdateTrackerModel = UpdateTrackerModel.empty()
        private var updatesNeeded: [DataManagerType] = []
        private var updatesCompleted: [DataManagerType] = []
        private var finishedCount: Int = 0
        
        func setCurrentUpdateTracker(_ value: UpdateTrackerModel) {
            currentUpdateTracker = value
        }
        
        func getCurrentUpdateTracker() -> UpdateTrackerModel {
            return currentUpdateTracker
        }
        
        func removeFromUpdatesNeededAndAddToCompleted(_ value: DataManagerType) {
            updatesNeeded.removeAll(where: { $0 == value })
            updatesCompleted.append(value)
        }
        
        func setUpdatesNeeded(_ value: [DataManagerType]) {
            updatesNeeded = value
        }
        
        func getUpdatesNeeded() -> [DataManagerType] {
            return updatesNeeded
        }
        
        func setUpdatesCompleted(_ value: [DataManagerType]) {
            updatesCompleted = value
        }
        
        func getUpdatesComplerted() -> [DataManagerType] {
            return updatesCompleted
        }
        
        func getFinishedCount() -> Int {
            return finishedCount
        }
        
        func incrementFinishedCount() {
            finishedCount += 1
        }
        
        func setFinishedCount(_ value: Int) {
            finishedCount = value
        }
    }
    
    //
    // MARK: - Settings Utils
    //
    
    func setLoading(_ loading: Bool, loadingText: String? = nil) async {
        await loadingActor.setLoading(loading)
        self.isLoadingMirror = loading
        if let loadingText = loadingText {
            self.loadingText = loadingText
        }
    }
    
    func setOfflineMode(_ offline: Bool) {
        offlineMode = offline
    }
    
    func setCurrentPlayerId(_ playerId: Int) {
        currentPlayerId = playerId
        LocalDataManager.shared.storePlayerId(playerId)
    }
    
    func setCurrentPlayerId(_ player: PlayerModel) {
        setCurrentPlayerId(player.id)
    }
    
    // TODO remove if not needed
    
//    func setUpdateCallback<T: View>(_ view: T, _ callback: @escaping () -> Void) {
//        updateCallbacks[getViewName(view)] = callback
//    }
//    
//    func clearUpdateCallback<T: View>(_ view: T.Type) {
//        updateCallbacks.removeValue(forKey: getViewName(view))
//    }
//    
//    func callUpdateCallback<T: View>(_ view: T.Type) {
//        updateCallbacks[getViewName(view)]?()
//    }
//    
//    func callUpdateCallbacks<T: View>(_ views: [T.Type]) {
//        for view in views {
//            callUpdateCallback(view)
//        }
//    }
//    
//    func setPassedData<T: View>(_ view: T, dataKey: DataManagerPassedDataKey, data: Any) {
//        passedData["\(getViewName(view))\(dataKey)"] = data
//    }
//    
//    func clearPassedData<T: View>(_ view: T.Type, dataKey: DataManagerPassedDataKey) {
//        passedData.removeValue(forKey: "\(getViewName(view))\(dataKey)")
//    }
//    
//    func getPassedData<T: View, K>(_ view: T.Type, dataKey: DataManagerPassedDataKey, clear: Bool = true) -> K? {
//        guard let data = passedData["\(getViewName(view))\(dataKey)"] as? K else { return nil }
//        if clear {
//            clearPassedData(view, dataKey: dataKey)
//        }
//        return data
//    }
//    
//    func getPassedData<T: View, K>(_ views: [T.Type], dataKey: DataManagerPassedDataKey, clear: Bool = true) -> K? {
//        for view in views {
//            guard let data = passedData["\(getViewName(view))\(dataKey)"] as? K else { continue }
//            if clear {
//                clearPassedData(view, dataKey: dataKey)
//            }
//            return data
//        }
//        return nil
//    }
    
    func setDebugMode(_ debug: Bool) {
        debugMode = debug
        Constants.ServiceOperationMode.updateServiceMode(debugMode ? .test : .prod)
    }
    
    //
    // MARK: - Unchanged Server Objects
    //
    
    @Published var announcements: [AnnouncementModel] = []
    @Published var contactRequests: [ContactRequestModel] = []
    @Published var featureFlags: [FeatureFlagModel] = []
    @Published var intrigues: [Int: IntrigueModel] = [:]
    @Published var researchProjects: [ResearchProjectModel] = []
    @Published var campStatus: CampStatusModel? = nil
    
    
    //
    // MARK: - Custom Models
    //
    
    @Published var skills: [FullSkillModel] = []
    @Published var events: [FullEventModel] = []
    @Published var characters: [FullCharacterModel] = []
    @Published var players: [FullPlayerModel] = []
    @Published var rulebook: Rulebook? = nil
    @Published var treatingWounds: UIImage? = nil
    
    //
    // MARK: - Editable In Place Variables
    //
    
    @Published var characterToEdit: FullCharacterModel? = nil
    @Published var gearToEdit: GearJsonModel? = nil
    @Published var fortificationToEdit: CampFortification? = nil
    
    //
    // MARK: Utils
    //
    
    func load(loadType: DataManagerLoadType = .downloadIfNecessary, stepFinished: @escaping () -> Void = {}, finished: @escaping () -> Void = {}) {
        var modLoadType = loadType
        if (offlineMode || debugMode) {
            modLoadType = .offline
        }
        Task {
            let previousLoading = await loadingActor.add(step: stepFinished, finished: finished)
            await setLoading(true)
            if !previousLoading {
                switch modLoadType {
                case .offline:
                    loadOffline()
                case .downloadIfNecessary:
                    loadDownloadIfNecessary()
                case .forceDownload:
                    loadForceDownload()
                }
            }
        }
    }
    
    private func loadOffline() {
        populateLocalData(false)
    }
    
    private func loadForceDownload() {
        Task {
            updateLoadingText("Force Clearing Data...")
            await loadingActor.setFirstLoad(true)
            LocalDataManager.shared.storeUpdateTracker(UpdateTrackerModel.empty())
            loadDownloadIfNecessary()
        }
        
    }
    
    private func loadDownloadIfNecessary() {
        UpdateTrackerService.getUpdateTracker { updateTrackerModel in
            Task {
                await self.handleUpdates(updateTrackerModel)
            }
        } failureCase: { error in
            self.loadOffline()
        }
        
    }
    
    private func handleUpdates(_ updateTracker: UpdateTrackerModel) async {
        await finishedCountActor.setUpdatesNeeded(LocalDataManager.shared.determineWhichTypesNeedUpdates(updateTracker))
        await finishedCountActor.setUpdatesCompleted([])
        await finishedCountActor.setCurrentUpdateTracker(updateTracker)
        await finishedCountActor.setFinishedCount(0)
        if await finishedCountActor.getUpdatesNeeded().isEmpty {
            populateLocalData(false)
        } else {
            Task {
                await updateLoadingText(generateLoadingText())
                await loadingActor.callStepCallbacks()
                let updatesNeededCopy = await finishedCountActor.getUpdatesNeeded()
                for updateType in updatesNeededCopy {
                    switch updateType {
                    case .updateTracker:
                        continue
                    case .announcements:
                        AnnouncementService.getAllAnnouncements { announcements in
                            LocalDataManager.shared.storeAnnouncements(announcements.announcements)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }
                    case .awards:
                        AwardService.getAllAwards { awardList in
                            LocalDataManager.shared.storeAwards(awards: awardList.awards)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .characters:
                        CharacterService.getAllFullCharacters { characterList in
                            LocalDataManager.shared.storeCharacters(characterList.characters)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .gear:
                        GearService.getAllGear { gearListModel in
                            LocalDataManager.shared.storeGear(gearListModel.charGear)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .characterSkills:
                        CharacterSkillService.getAllCharacterSkills { charSkills in
                            LocalDataManager.shared.storeCharacterSkills(charSkills.charSkills)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .contactRequests:
                        ContactService.getAllContactRequests { contactRequestList in
                            LocalDataManager.shared.storeContactRequests(contactRequestList.contactRequests)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .events:
                        EventService.getAllEvents { eventList in
                            LocalDataManager.shared.storeEvents(eventList.events)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .eventAttendees:
                        EventAttendeeService.getAllEventAttendees { attendeeList in
                            LocalDataManager.shared.storeEventAttendees(attendeeList.eventAttendees)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .preregs:
                        EventPreregService.getAllPreregs { preregList in
                            LocalDataManager.shared.storePreregs(preregList.eventPreregs)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .featureFlags:
                        FeatureFlagService.getAllFeatureFlags { featureFlags in
                            LocalDataManager.shared.storeFeatureFlags(featureFlags.results)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .intrigues:
                        IntrigueService.getAllIntrigues { intrigue in
                            LocalDataManager.shared.storeIntrigues(intrigue.intrigues)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .players:
                        PlayerService.getAllPlayers { playerList in
                            LocalDataManager.shared.storePlayers(playerList.players)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .profileImages:
                        ProfileImageService.getAllProfileImages { profileImages in
                            LocalDataManager.shared.storeProfileImages(profileImages.profileImages)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .researchProjects:
                        ResearchProjectService.getAllResearchProjects { projectList in
                            LocalDataManager.shared.storeResearchProjects(projectList.researchProjects)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .skills:
                        SkillService.getAllSkills { skillListModel in
                            LocalDataManager.shared.storeSkills(skillListModel.results)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .skillCategories:
                        SkillCategoryService.getAllSkillCategories { skillCategories in
                            LocalDataManager.shared.storeSkillCategories(skillCategories.results)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .skillPrereqs:
                        SkillPrereqService.getAllSkillPrereqs { skillPrereqListModel in
                            LocalDataManager.shared.storeSkillPrereqs(skillPrereqListModel.skillPrereqs)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .xpReductions:
                        SpecialClassXpReductionService.getAllXpReductions { xpReductions in
                            LocalDataManager.shared.storeXpReductions(xpReductions.specialClassXpReductions)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    case .rulebook:
                        guard let url = URL(string: Constants.urls.rulebook) else {
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                            continue
                        }
                        do {
                            let html = try String(contentsOf: url)
                            OldLocalDataHandler.shared.storeRulebook(html)
                            let rb = RulebookUtils.parseDocAsRulebook(document: try SwiftSoup.parse(html), version: updateTracker.rulebookVersion)
                            LocalDataManager.shared.storeRulebook(rb)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } catch {
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }
                    case .treatingWounds:
                        ImageDownloader().downloadReturningImage(key: .treatingWounds) { imageData in
                            if let data = imageData {
                                LocalDataManager.shared.storeTreatingWounds(data)
                                Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                            } else {
                                Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                            }
                        }
                    case .campStatus:
                        CampStatusService.getCampStatus { campStatusModel in
                            LocalDataManager.shared.storeCampStatus(campStatusModel)
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: true, localUpdatesNeeded: updatesNeededCopy)
                            }
                        } failureCase: { error in
                            Task {
                                await self.serviceFinished(type: updateType, succeeded: false, localUpdatesNeeded: updatesNeededCopy)
                            }
                        }

                    }
                }
            }
            
        }
    }
    
    private func generateLoadingText() async -> String {
        var text = "Loading:\n"
        for (index, update) in await finishedCountActor.getUpdatesNeeded().enumerated() {
            if index > 0 {
                // Two per line
                text += (index % 2 == 0) ? "\n" : ", "
            }
            text += update.rawValue.replacingOccurrences(of: "_", with: " ").capitalizingFirstLetterOfEachWord()
        }
        text += "..."
        return text
    }
    
    private func serviceFinished(type: DataManagerType, succeeded: Bool, localUpdatesNeeded: [DataManagerType]) async {
        if succeeded {
            await finishedCountActor.removeFromUpdatesNeededAndAddToCompleted(type)
        }
        await finishedCountActor.incrementFinishedCount()
        await updateLoadingText(generateLoadingText())
        await loadingActor.callStepCallbacks()
        if await finishedCountActor.getFinishedCount() == localUpdatesNeeded.count {
            updateLoadingText("Building Local Data Models...")
            await loadingActor.callStepCallbacks()
            LocalDataManager.shared.updatesSucceeded(await finishedCountActor.getCurrentUpdateTracker(), successfulUpdates: await finishedCountActor.getUpdatesComplerted())
            populateLocalData(true)
        }
    }
    
    private func populateLocalData(_ updatesDownloaded: Bool) {
        if debugMode {
            Task {
                if await loadingActor.getFirstLoad() || updatesDownloaded {
                    let md = getMockData()
                    
                    updateLoadingText("Populating Mock Data In Memory...")
                    await loadingActor.callStepCallbacks()
                    await loadingActor.setFirstLoad(false)
                    
                    // Normal Models
                    self.announcements = md.allAnnouncements.announcements
                    self.contactRequests = md.contacts.contactRequests
                    self.featureFlags = md.featureFlagList.results
                    self.intrigues = md.intriguesByEvent()
                    self.researchProjects = md.researchProjects.researchProjects
                    self.campStatus = md.campStatus
                    
                    // Built Models
                    self.skills = md.fullSkills()
                    self.events = md.fullEvents()
                    self.characters = md.fullCharacters()
                    self.players = md.fullPlayers()
                    self.rulebook = md.rulebook
                    self.treatingWounds = UIImage(data: LocalDataManager.shared.getTreatingWounds() ?? Data())
                    self.currentPlayerId = md.player().id
                }
                updateLoadingText("")
                await setLoading(false)
                
                await loadingActor.callStepCallbacks()
                await loadingActor.callCallbacks()
                await loadingActor.clearCallbacks()
                await loadingActor.clearStepCallbacks()
            }
        } else {
            Task {
                if await loadingActor.getFirstLoad() || updatesDownloaded {
                    updateLoadingText("Populating Data In Memory...")
                    await loadingActor.callStepCallbacks()
                    await loadingActor.setFirstLoad(false)
                    
                    // Normal Models
                    self.announcements = LocalDataManager.shared.getAnnouncements()
                    self.contactRequests = LocalDataManager.shared.getContactRequests()
                    self.featureFlags = LocalDataManager.shared.getFeatureFlags()
                    self.intrigues = LocalDataManager.shared.getIntrigues()
                    self.researchProjects = LocalDataManager.shared.getResearchProjects()
                    self.campStatus = LocalDataManager.shared.getCampStatus()
                    
                    // Built Models
                    self.skills = LocalDataManager.shared.getFullSkills()
                    self.events = LocalDataManager.shared.getFullEvents()
                    self.characters = LocalDataManager.shared.getFullCharacters()
                    self.players = LocalDataManager.shared.getFullPlayers()
                    self.rulebook = LocalDataManager.shared.getRulebook()
                    self.treatingWounds = UIImage(data: LocalDataManager.shared.getTreatingWounds() ?? Data())
                    self.currentPlayerId = LocalDataManager.shared.getPlayerId()
                }
                updateLoadingText("")
                await setLoading(false)
                await loadingActor.callStepCallbacks()
                await loadingActor.callCallbacks()
                await loadingActor.clearCallbacks()
                await loadingActor.clearStepCallbacks()
            }
        }
    }
    
    private func updateLoadingText(_ new: String) {
        loadingText = new
    }
    
    static func forceReset() {
        shared = DataManager()
    }
    
    //
    // MARK: - Other Utils
    //
    
    func playerIsCurrentPlayer(_ id: Int) -> Bool {
        return id == currentPlayerId
    }
    
    func playerIsCurrentPlayer(_ player: FullPlayerModel) -> Bool {
        return playerIsCurrentPlayer(player.id)
    }
    
    func getTitlePotentiallyOffline(_ baseText: String) -> String {
        return offlineMode ? "\(baseText)\n[Offline]" : baseText
    }
    
    func getSkillsAsFCMSM() -> [FullCharacterModifiedSkillModel] {
        return skills.map { $0.fullCharacterModifiedSkillModel() }
    }
    
    func getCurrentPlayer() -> FullPlayerModel? {
        return players.first(where: { $0.id == currentPlayerId })
    }
    
    func getPlayerForCharacter(_ character: FullCharacterModel) -> FullPlayerModel {
        return players.first(where: { $0.id == character.playerId })!
    }
    
    func getActiveCharacter() -> FullCharacterModel? {
        return getCurrentPlayer()?.getActiveCharacter()
    }
    
    func getAllCharacters(_ type: CharacterType) -> [FullCharacterModel] {
        return getAllCharacters([type])
    }
    
    func getAllCharacters(_ types: [CharacterType]) -> [FullCharacterModel] {
        return characters.filter { types.contains($0.characterType()) }
    }
    
    func getAllCharacters() -> [FullCharacterModel] {
        return characters
    }
    
    func getCharacter(_ id: Int) -> FullCharacterModel? {
        return characters.first(where: { $0.id == id })
    }
    
    func getOngoingEvent() -> FullEventModel? {
        return events.first(where: { $0.isOngoing() })
    }
    
    private func getEventToday() -> FullEventModel? {
        return events.first(where: { $0.isToday() })
    }
    
    func getOngoingOrTodayEvent() -> FullEventModel? {
        return getOngoingEvent() ?? getEventToday()
    }
    
    func getRelevantEvents() -> [FullEventModel] {
        return events.filter({ $0.isRelevant() })
    }
    
    func getCharactersWhoNeedBiosApproved() -> [FullCharacterModel] {
        return characters.filter({ !$0.approvedBio && $0.bio.isNotEmpty })
    }
    
    func popToRoot() {
        runOnMainThread {
            self.actionState = 0
        }
    }
    
}
