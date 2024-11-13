//
//  LutCardView.swift
//  SegmentAnywhere
//
//  Created by hansoong on 1/7/24.
//

import SwiftUI

struct CardView: View {
    var image: UIImage
    var condition: Bool
    var cardName: String
    var showFavorite: Bool = false
    var favCondition: Bool = false
    let favOnTap: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .opacity(condition ? 0.4 : 0)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width - UILayout.CommonGap/4, height: geo.size.height - UILayout.CommonGap/4, alignment: .center)
                    .allowsHitTesting(false)
                    .clipped()
                    .opacity(condition ? 0.5 : 1)
//                    .border(Color.checkred.opacity(0.5))
                
                VStack (spacing: 0){
                    
                    Spacer()
                    Text(cardName)
                        .font(.appTextFont)
                        .foregroundStyle(condition ? Color.appDarkGray : Color.white)
                        .lineLimit(1)
                        .frame(width: geo.size.width, height: 20)
//                        .border(Color.checkgreen.opacity(0.5))
                        .background(
                            Rectangle().fill(
                                condition ? Color.appMain : Color.appDarkGray
                            )
                        )
                }
//                .border(Color.checkcyan.opacity(0.5))
                
                if showFavorite {
                    Image(systemName:"heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(UILayout.CommonGap/2)
                        .foregroundStyle(favCondition ? Color.appMain : Color.white.opacity(0.7))
                        .frame(width: UILayout.LUTFavoriteIconSize, height: UILayout.LUTFavoriteIconSize)
//                        .border(Color.checkred.opacity(0.5))
                        .offset(x: geo.size.width/2 - UILayout.LUTFavoriteIconSize/2, y: -(geo.size.width/2 - UILayout.LUTFavoriteIconSize/2))
//                        .position(x: (geo.size.width - UILayout.LUTFavoriteIconSize), y: -UILayout.LUTFavoriteIconSize/2)
                        .onTapGesture {
                            favOnTap()
                        }
                }
            }
        }
        .cardStyle(condition: condition)
    }
}

struct LutCardView: View {
    
    var lutItem: LUTItem!
    @Binding var favoriteLUT: [String]
    @Binding var showingRenameAlert : Bool
    @Binding var selectedLutItem : LUTItem!
    @EnvironmentObject var photoManager : PhotoManager
    @EnvironmentObject var lutViewModel : LUTViewModel
    
    var body: some View {
        
        let name = lutItem.name.lowercased()
        
        CardView(
            image: lutItem.getLUTImage(inputImage: photoManager.iconCurrentDisplayImage),
            condition: lutViewModel.currentLUTItem == lutItem,
            cardName: lutItem.name,
            showFavorite: true,
            favCondition: favoriteLUT.contains(name),
            favOnTap: favoriteTap
        )
        .contextMenu {
            menuItems(for: lutItem)
        }
    }
    
    func favoriteTap() -> Void {
        let name = lutItem.name.lowercased()
        if favoriteLUT.contains(name) {
            let index = favoriteLUT.firstIndex(of: name)!
            favoriteLUT.remove(at: index)
            if favoriteLUT.isEmpty {
                lutViewModel.lutOption = .ALL
            }
        } else {
            favoriteLUT.append(name)
        }
    }
    
    
    func menuItems(for lutItem: LUTItem) -> some View {
            Group {
                Button("Rename", action: {
                    selectedLutItem = lutItem
                    showingRenameAlert.toggle()
                })
                Button("Delete", action: {
                    lutViewModel.removeItem(lutItem)
                })
            }
        }
}

struct EffectCardView: View {
    @EnvironmentObject var effectFilter : EffectFilterViewModel
    @EnvironmentObject var photoManager : PhotoManager
    @Binding var effectList : [CIFilterItem]
    var index: Int
    
    var body: some View {
        CardView(
            image: effectFilter.getEffectImage(effect: effectList[index].ciFilterEffect, inputImage: photoManager.iconCurrentDisplayImage),
            condition: false,
            cardName: effectList[index].iconName,
            favOnTap: {}
        )
    }
}
