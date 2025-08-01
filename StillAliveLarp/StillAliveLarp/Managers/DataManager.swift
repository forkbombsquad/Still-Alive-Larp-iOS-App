//
//  DataManager.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

import SwiftUI

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
    
    @Published private(set) var debugMode: Bool = false
    @Published private(set) var offlineMode: Bool = false
    @Published private(set) var currentPlayerId: Int = -1
    @Published private var updateCallbacks: [String: () -> Void] = [:]
    @Published private var passedData: [String: Any] = [:]
    
    @Published private var currentUpdateTracker: UpdateTrackerModel = UpdateTrackerModel.empty()
    @Published private var updatesNeeded: [DataManagerType] = []
    @Published private var updatesCompleted: [DataManagerType] = []
    @Published private var finishedCount: Int = 0
    
    @Published var loadingText: String = ""
    let loadingActor = LoadingActor()
    
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
            loading = true
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
    }
    
    actor finishedCountActor {
        
    }
    
    //
    // MARK: - Settings Utils
    //
    
    func setOfflineMode(_ offline: Bool) {
        offlineMode = offline
    }
    
    func setCurrentPlayerId(_ playerId: Int) {
        // TODO store the player id in LocalDataManager
        currentPlayerId = playerId
    }
    
    func setCurrentPlayerId(_ player: PlayerModel) {
        setCurrentPlayerId(player.id)
    }
    
    func setUpdateCallback<T: View>(_ view: T, _ callback: @escaping () -> Void) {
        updateCallbacks[getViewName(view)] = callback
    }
    
    func clearUpdateCallback<T: View>(_ view: T.Type) {
        updateCallbacks.removeValue(forKey: getViewName(view))
    }
    
    func callUpdateCallback<T: View>(_ view: T.Type) {
        updateCallbacks[getViewName(view)]?()
    }
    
    func callUpdateCallbacks<T: View>(_ views: [T.Type]) {
        for view in views {
            callUpdateCallback(view)
        }
    }
    
    func setPassedData<T: View>(_ view: T, dataKey: DataManagerPassedDataKey, data: Any) {
        passedData["\(getViewName(view))\(dataKey)"]
    }
    
    func clearPassedData<T: View>(_ view: T.Type, dataKey: DataManagerPassedDataKey) {
        passedData.removeValue(forKey: "\(getViewName(view))\(dataKey)")
    }
    
    func getPassedData<T: View, K>(_ view: T.Type, dataKey: DataManagerPassedDataKey, clear: Bool = true) -> K? {
        guard let data = passedData["\(getViewName(view))\(dataKey)"] as? K else { return nil }
        if clear {
            clearPassedData(view, dataKey: dataKey)
        }
        return data
    }
    
    func getPassedData<T: View, K>(_ views: [T.Type], dataKey: DataManagerPassedDataKey, clear: Bool = true) -> K? {
        for view in views {
            guard let data = passedData["\(getViewName(view))\(dataKey)"] as? K else { continue }
            if clear {
                clearPassedData(view, dataKey: dataKey)
            }
            return data
        }
        return nil
    }
    
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
    // TODO
//    @Published var campStatus: CampStatusModel? = nil
    
    
    //
    // MARK: - Custom Models
    //
    
    @Published var skills: [FullSkillModel] = []
    @Published var events: [FullEventModel] = []
    @Published var characters: [OldFullCharacterModel] = []
    @Published var players: [FullPlayerModel] = []
    @Published var rulebook: Rulebook? = nil
    @Published var treatingWounds: UIImage? = nil
    
    //
    // MARK: - Editable In Place Variables
    //
    
    @Published var characterToEdit: OldFullCharacterModel? = nil
    @Published var gearToEdit: GearJsonModel? = nil
    // TODO
//    @Published var fortificationToEdit: CampFortification? = nil
    
    //
    // MARK: Utils
    //
    
    func load(loadType: DataManagerLoadType = .downloadIfNecessary, stepFinished: @escaping () -> Void = {}, finished: @escaping () -> Void) {
        var modLoadType = loadType
        if (offlineMode || debugMode) {
            modLoadType = .offline
        }
        Task {
            let previousLoading = await loadingActor.add(step: stepFinished, finished: finished)
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
            // TODO
    //        LocalDataManager.shared.storeUpdateTracker(UpdateTrackerModel.empty())
            loadDownloadIfNecessary()
        }

    }
    
    private func loadDownloadIfNecessary() {
        UpdateTrackerService.getUpdateTracker { updateTrackerModel in
            self.handleUpdates(updateTrackerModel)
        } failureCase: { error in
            self.loadOffline()
        }

    }
    
    private func handleUpdates(_ updateTracker: UpdateTrackerModel) {
        // TODO
    }
    
    private func serviceFinished(type: DataManagerType, succeeded: Bool, localUpdatesNeeded: [DataManagerType]) {
        // TODO
    }
    
    private func populateLocalData(_ updatesDownloaded: Bool) {
        // TODO
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
    
    // TODO loading layout
    func handleLoadingTextAndHidingViews(/*loadingLayout: LoadingLayout, */ thingsToHideWhileLoading: [any View] = [], runIfLoading: () -> Void = {}, runIfNotLoading: () -> Void) {
        
    }
    
    /*
     
     fun handleLoadingTextAndHidingViews(loadingLayout: LoadingLayout, thingsToHideWhileLoading: List<View> = listOf(), runIfLoading: () -> Unit = {}, runIfNotLoading: () -> Unit) {
         if (loading) {
             loadingLayout.setLoadingText(loadingText)
             thingsToHideWhileLoading.forEach { it.isGone = true }
             runIfLoading()
         } else {
             loadingLayout.setLoading(false)
             thingsToHideWhileLoading.forEach { it.isGone = false }
             runIfNotLoading()
         }
     }
     */
    
}
