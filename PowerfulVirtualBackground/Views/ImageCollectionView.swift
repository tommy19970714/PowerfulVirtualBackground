//
//  ImageCollectionView.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation
import SwiftUI

struct ImageCollectionView: View {
    var images: FetchedResults<BackgroundImage>
    var tappedAdd: ()->Void
    var tappedDelete: (BackgroundImage)->Void
    let columns: [GridItem] = [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 15)]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, alignment: .center, spacing: 15) {
                ForEach(images, id: \BackgroundImage.self) { item in
                    ZStack(alignment: .topTrailing) {
                        let img = NSImage(data: item.image!)!
                        Image(nsImage: img)
                            .resizable()
                            .frame(width: 180, height: 100)
                            .aspectRatio(1, contentMode: .fill)
                            .cornerRadius(8)
                            .onTapGesture {
                                UserDefaultsUtil.backgroundImageData = item.image
                                NotificationCenter.default.post(name: NSNotification.selectBackgroundImage, object: self, userInfo: nil)
                            }
                        ZStack {
                            Rectangle().foregroundColor(.red)
                                .cornerRadius(30)
                                .frame(width: 15, height: 15)
                                .padding(4)
                            Text("×")
                                .foregroundColor(.white)
                                .padding(.bottom, 2)
                        }.onTapGesture {
                            tappedDelete(item)
                        }
                    }
                }
                ZStack {
                    Rectangle().foregroundColor(.white)
                        .frame(width: 180, height: 100)
                        .cornerRadius(8)
                    Text("+").foregroundColor(.black)
                }.onTapGesture {
                    tappedAdd()
                }
            }
        }
    }
}
