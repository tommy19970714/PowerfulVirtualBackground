//
//  ContentView.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/18.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \BackgroundImage.timestamp, ascending: true)],
            animation: .default)
    private var images: FetchedResults<BackgroundImage>
    
    var body: some View {
        VStack(spacing: 16) {
            CameraView()
            Spacer()
            .frame(maxHeight: 20)
            ImageCollectionView(images: images, tappedAdd: {
                if let img = selectImage() {
                    addItem(img)
                }
            }, tappedDelete: { item in
                deleteItem(item)
            })
        }.frame(width: 640, height: 600, alignment: .center)
    }
    
    private func selectImage() -> NSImage? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            return NSImage(contentsOf: url)
        }
        return nil
    }
    
    private func addItem(_ image: NSImage) {
        withAnimation {
            let newItem = BackgroundImage(context: viewContext)
            newItem.timestamp = Date()
            newItem.image = image.tiffRepresentation
            try? viewContext.save()
        }
    }
    
    private func deleteItem(_ item: BackgroundImage) {
        withAnimation {
            viewContext.delete(item)
            try? viewContext.save()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
