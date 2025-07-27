//
//  CanvasSkillCell.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/18/25.
//

import SwiftUI

enum PurchaseState {
    case purchased, couldPurchase, cantPurchase
}

struct CanvasSkillCell: View {
    
    let expanded: Bool
    let skill: OldFullSkillModel
    let allowPurchase: Bool
    let purchaseState: PurchaseState
    let loadingPurchase: Bool
    let collapsedWidth: CGFloat
    let expandedWidth: CGFloat
    let loadingText: String
    
    let largeFont: Font = .system(size: 40, weight: .bold)
    let medFont: Font = .system(size: 34, weight: .bold)
    let smallFont: Font = .system(size: 30, weight: .bold)
    let smallFontReg: Font = .system(size: 30, weight: .regular)
    
    var body: some View {
        VStack {
            let bubbleNum = getSkillBubbleNum()
            if bubbleNum > 1 {
                ZStack {
                    let cSize = expanded ? (expandedWidth / 5) : collapsedWidth / 5
                    Circle()
                        .frame(width: cSize, height: cSize)
                        .foregroundColor(.black)
                    Circle()
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 5))
                        .frame(width: cSize, height: cSize)
                    Text(bubbleNum.stringValue)
                        .font(medFont)
                        .foregroundColor(.white)
                }.padding(.bottom, -4)
            }
            if let skillTopBoxText = skillTopBoxText() {
                VStack {
                    Text(skillTopBoxText)
                        .font(smallFont)
                        .foregroundStyle(Color.white)
                        .padding(16)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .shadow(color: .black, radius: 1)
                }
                .background(Color.black)
                .frame(width: expanded ? expandedWidth : collapsedWidth, alignment: .center)
                .overlay(
                    Rectangle().strokeBorder(Color.white, lineWidth: 2)
                )
            }
            VStack {
                // Rest of cell
                if expanded {
                    VStack {
                        HStack {
                            Text(skill.name)
                                .font(largeFont)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .shadow(color: .black, radius: 0.4)
                                .shadow(color: .black, radius: 0.4)
                                .shadow(color: .black, radius: 0.4)
                                .shadow(color: .black, radius: 0.4)
                            Text(skill.getTypeText())
                                .font(medFont)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .multilineTextAlignment(.trailing)
                                .frame(alignment: .trailing)
                                .fixedSize(horizontal: false, vertical: true)
                                .shadow(color: .black, radius: 0.4)
                                .shadow(color: .black, radius: 0.4)
                                .shadow(color: .black, radius: 0.4)
                                .shadow(color: .black, radius: 0.4)
                        }
                        Divider()
                            .frame(height: 2)
                            .overlay(Color.darkGray)
                            .padding(.horizontal, 16)
                        Text(getXpRowText())
                            .font(smallFont)
                            .foregroundStyle(Color.white)
                            .padding(16)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .shadow(color: .black, radius: 0.4)
                            .shadow(color: .black, radius: 0.4)
                            .shadow(color: .black, radius: 0.4)
                            .shadow(color: .black, radius: 0.4)
                    }
                    .frame(maxWidth: .infinity)
                    Divider()
                        .frame(height: 2)
                        .overlay(Color.darkGray)
                        .padding(.horizontal, 16)
                    if skill.prereqs.isNotEmpty {
                        
                        Text("Prerequisites")
                            .font(medFont)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .shadow(color: .black, radius: 0.4)
                            .shadow(color: .black, radius: 0.4)
                            .shadow(color: .black, radius: 0.4)
                            .shadow(color: .black, radius: 0.4)
                        LazyVStack {
                            ForEach(skill.prereqs) { prereq in
                                Text(prereq.name)
                                    .font(smallFontReg)
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 16)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .shadow(color: .black, radius: 0.4)
                                    .shadow(color: .black, radius: 0.4)
                                    .shadow(color: .black, radius: 0.4)
                                    .shadow(color: .black, radius: 0.4)
                            }
                        }
                        Divider()
                            .frame(height: 2)
                            .overlay(Color.darkGray)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                    }
                    Text(skill.description)
                        .font(smallFontReg)
                        .foregroundStyle(Color.white)
                        .padding(16)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .shadow(color: .black, radius: 0.4)
                        .shadow(color: .black, radius: 0.4)
                        .shadow(color: .black, radius: 0.4)
                        .shadow(color: .black, radius: 0.4)
                    if allowPurchase {
                        LoadingButtonView(.constant(loadingPurchase), loadingText: .constant(loadingText), width: expandedWidth - 100, buttonText: "Purchase", font: largeFont) {}
                        .padding([.horizontal, .bottom], 32)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    Text(skill.name)
                        .font(largeFont)
                        .foregroundStyle(Color.white)
                        .padding(16)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: collapsedWidth, alignment: .center)
                        .shadow(color: .black, radius: 1)
                }
            }
            .padding(0)
            .background(
                LinearGradient(colors: [getTopColor(), getBottomColor()], startPoint: .top, endPoint: .bottom)
            )
        }
        .frame(width: expanded ? expandedWidth : collapsedWidth, alignment: .center)
    }
    
    private func getSkillBubbleNum() -> Int {
        return skill.prereqs.count
    }
    
    func getTopColor() -> Color {
        if purchaseState == .cantPurchase {
            return Color(hex: "#797979")
        }
        switch skill.skillTypeId {
            case Constants.SkillTypes.combat:
                if purchaseState == .purchased {
                    return Color(hex: "#F7C9C6")
                } else if purchaseState == .couldPurchase {
                    return Color(hex: "#EA6E69")
                }
            case Constants.SkillTypes.profession:
                if purchaseState == .purchased {
                    return Color(hex: "#CAE1C5")
                } else if purchaseState == .couldPurchase {
                    return Color(hex: "#667D61")
                }
            case Constants.SkillTypes.talent:
                if purchaseState == .purchased {
                    return Color(hex: "#D8E7FB")
                } else if purchaseState == .couldPurchase {
                    return Color(hex: "#748397")
                }
            default:
                break
        }
        return .midRed
    }
    
    func getBottomColor() -> Color {
        if purchaseState == .cantPurchase {
            return Color(hex: "#353535")
        }
        switch skill.skillTypeId {
            case Constants.SkillTypes.combat:
                if purchaseState == .purchased {
                    return Color(hex: "#EA6E69")
                } else if purchaseState == .couldPurchase {
                    return Color(hex: "#860A05")
                }
            case Constants.SkillTypes.profession:
                if purchaseState == .purchased {
                    return Color(hex: "#98D078")
                } else if purchaseState == .couldPurchase {
                    return Color(hex: "#346C14")
                }
            case Constants.SkillTypes.talent:
                if purchaseState == .purchased {
                    return Color(hex: "#7FA7E0")
                } else if purchaseState == .couldPurchase {
                    return Color(hex: "#1B437C")
                }
            default:
                break
        }
        return .midRed
    }
    
    func getXpRowText() -> String {
        var xpRow = "\(skill.xpCost)xp"
        if skill.prestigeCost.intValueDefaultZero > 0 {
            xpRow += " | \(skill.prestigeCost)pp"
        }
        if skill.minInfection.intValueDefaultZero > 0 {
            xpRow += " | \(skill.minInfection)% Inf Threshold"
        }
        return xpRow
    }
    
    func skillTopBoxText() -> String? {
        var str = ""
        if skill.skillCategoryId == Constants.SpecificSkillCategories.infected {
            str = "At least \(skill.minInfection)% Infection Rating Required"
        } else if skill.skillCategoryId == Constants.SpecificSkillCategories.spec {
            str = "You may only select 1 Tier-\(skill.xpCost) specialization skill"
        } else if skill.skillCategoryId == Constants.SpecificSkillCategories.prestige {
            str = "Requires \(skill.prestigeCost) Prestige Point"
        }
        return str.isEmpty ? nil : str
    }
    
}

#Preview {
    let md = getMockData()
    let freeSkill = 6
    let longSkill = 72
    let prestigeSkill = 23
    let infSkill = 40
    let specSkill = 19
    let manyPrereqs = 47
    CanvasSkillCell(expanded: true, skill: md.fullSkills().first(where: { $0.id == manyPrereqs })!, allowPurchase: true, purchaseState: .purchased, loadingPurchase: false, collapsedWidth: 300, expandedWidth: 300, loadingText: "Purchasing...")
}

struct SkillCellMeasurer: View {
    let skill: OldFullSkillModel

    let expanded: Bool
    let allowPurchase: Bool
    let purchaseState: PurchaseState
    let loadingPurchase: Bool
    let collapsedWidth: CGFloat
    let expandedWidth: CGFloat

    var body: some View {
        ZStack {
            CanvasSkillCell(
                expanded: expanded,
                skill: skill,
                allowPurchase: allowPurchase,
                purchaseState: purchaseState,
                loadingPurchase: loadingPurchase,
                collapsedWidth: collapsedWidth,
                expandedWidth: expandedWidth,
                loadingText: "Purchasing..."
            )
            .fixedSize(horizontal: false, vertical: true)
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: SkillSizePreferenceKey.self,
                        value: [skill.id: geo.size]
                    )
            }
        }
        .frame(width: expanded ? expandedWidth : collapsedWidth)
    }
}


struct SkillSizePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGSize] = [:]
    static func reduce(value: inout [Int: CGSize], nextValue: () -> [Int: CGSize]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
