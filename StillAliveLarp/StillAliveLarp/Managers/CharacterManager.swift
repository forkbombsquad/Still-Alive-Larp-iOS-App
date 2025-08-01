//
//  CharacterManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import Foundation
// TODO remove this boi completely

class CharacterManager {

    static func forceReset() {
        shared.character = nil
    }

    static let shared = CharacterManager()

    private var character: OldFullCharacterModel?
    private var fetching = false

    private var completionBlocks = [((character: OldFullCharacterModel?) -> Void)?]()

    private init() {}
    
    func fetchFullCharacter(characterId: Int, callback: @escaping (OldFullCharacterModel?) -> Void) {
        CharacterService.getCharacter(characterId) { characterModel in
            var character = OldFullCharacterModel(characterModel)
            SkillManager.shared.getSkills() { skills in
                CharacterSkillService.getAllSkillsForChar(character.id, onSuccess: { charSkills in
                    for cs in charSkills.charSkills {
                        guard let sk = skills.first(where: { $0.id == cs.skillId }) else { continue }
                        character.skills.append(sk)
                    }
                    callback(character)

                }, failureCase: { error in
                    callback(nil)
                })
            }
        } failureCase: { error in
            callback(nil)
        }

    }

    func getActiveCharacterForOtherPlayer(_ playerId: Int, completion: @escaping (_ character: OldFullCharacterModel?) -> Void, failureCase: @escaping FailureCase) {
        CharacterService.getAllPlayerCharacters(playerId, onSuccess: { characterListModel in
            guard let aliveCharacter = characterListModel.characters.first(where: { $0.isAlive.boolValue ?? false }) else {
                completion(nil)
                return
            }

            CharacterService.getCharacter(aliveCharacter.id, onSuccess: { characterModel in
                var character = OldFullCharacterModel(characterModel)

                SkillManager.shared.getSkills() { skills in
                    CharacterSkillService.getAllSkillsForChar(character.id, onSuccess: { charSkills in
                        for cs in charSkills.charSkills {
                            guard let sk = skills.first(where: { $0.id == cs.skillId }) else { continue }
                            character.skills.append(sk)
                        }
                        completion(character)

                    }, failureCase: failureCase)
                }
            }, failureCase: failureCase)

        }, failureCase: failureCase)
    }

    func fetchActiveCharacter(overrideLocal: Bool = false, _ completion: ((_ character: OldFullCharacterModel?) -> Void)? = nil) {
        if !overrideLocal, let character = character {
            completion?(character)
        } else {
            guard let player = PlayerManager.shared.getPlayer() else {
                completion?(nil)
                return
            }
            completionBlocks.append(completion)
            guard !fetching else { return }
            fetching = true
            CharacterService.getAllPlayerCharacters(player.id) { characterListModel in
                guard let aliveCharacter = characterListModel.characters.first(where: { $0.isAlive.boolValue ?? false }) else {
                    self.character = nil
                    for cb in self.completionBlocks {
                        cb?(nil)
                    }
                    self.fetching = false
                    return
                }
                CharacterService.getCharacter(aliveCharacter.id) { characterModel in

                    self.character = OldFullCharacterModel(characterModel)

                    SkillManager.shared.getSkills() { skills in
                        CharacterSkillService.getAllSkillsForChar(self.character?.id ?? 0) { charSkills in
                            for cs in charSkills.charSkills {
                                guard let sk = skills.first(where: { $0.id == cs.skillId }) else { continue }
                                self.character?.skills.append(sk)
                            }

                            if let c = self.character {
                                OldLocalDataHandler.shared.storeCharacter(c)
                            }

                            self.fetching = false
                            for cb in self.completionBlocks {
                                cb?(self.character)
                            }
                            self.completionBlocks = []

                        } failureCase: { _ in
                            self.fetching = false
                            for cb in self.completionBlocks {
                                cb?(self.character)
                            }
                            self.completionBlocks = []
                        }
                    }
                } failureCase: { _ in
                    self.fetching = false
                    for cb in self.completionBlocks {
                        cb?(self.character)
                    }
                    self.completionBlocks = []
                }
            } failureCase: { _ in
                self.fetching = false
                for cb in self.completionBlocks {
                    cb?(self.character)
                }
                self.completionBlocks = []
            }
        }
    }

    func newCharacterCreated(_ characterModel: CharacterModel) {
        self.character = OldFullCharacterModel(characterModel)
        fetching = true
        SkillManager.shared.getSkills() { skills in
            CharacterSkillService.getAllSkillsForChar(self.character?.id ?? 0) { charSkills in
                for cs in charSkills.charSkills {
                    guard let sk = skills.first(where: { $0.id == cs.skillId }) else { continue }
                    self.character?.skills.append(sk)
                }

                if let c = self.character {
                    OldLocalDataHandler.shared.storeCharacter(c)
                }

                self.fetching = false
                for cb in self.completionBlocks {
                    cb?(self.character)
                }
                self.completionBlocks = []

            } failureCase: { _ in
                self.fetching = false
                for cb in self.completionBlocks {
                    cb?(self.character)
                }
                self.completionBlocks = []
            }
        }
    }

}
